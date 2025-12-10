function myDSPProject()
% MYDSPPROJECT
% Full speech-processing pipeline:
%  - Load audio (wav/mp3/mp4)
%  - Convert to mono
%  - Frame into overlapping windows
%  - VAD using RMS threshold
%  - STFT spectrogram + pitch()
%  - Base-frequency estimation from spectrum
%  - Harmonic pseudo-speech synthesis
%  - Plots + CSV/WAV export next to input file

    %% 1) Load audio and convert to mono
    [sig, fs, baseName, pathName] = load_audio_and_mono();

    %% 2) Frame signal into overlapping windows
    [frames, frameStep, winSize, overlap] = frame_signal(sig, fs);

    %% 3) VAD using RMS
    [vadBinary, vadTime, frameRMS] = compute_vad(frames, fs, frameStep); %#ok<NASGU>

    %% 4) Spectrogram (STFT) + pitch track
    [S, S_db, F, T, pitchValues] = compute_spectrogram_and_pitch(sig, fs, winSize, overlap);

    %% 5) Harmonic pseudo-speech synthesis
    synthesizedSignal = synthesize_pseudo_speech(sig, fs, pitchValues, vadBinary, frameStep, winSize);

    %% 6) Base-frequency from magnitude spectrum (peak per frame)
    baseFrequency = compute_base_frequency_from_spectrum(S, F);

    %% 7) Plot results
    plot_results(sig, fs, vadBinary, vadTime, S_db, F, T, pitchValues, baseFrequency, synthesizedSignal);

    %% 8) Export CSV + WAV next to input file
    export_results(vadTime, vadBinary, T, pitchValues, synthesizedSignal, fs, baseName, pathName);
end

%% ===================== Helper Functions =====================

function [sig, fs, baseName, pathName] = load_audio_and_mono()
    % בחירת קובץ אודיו/וידאו
    [fileName, pathName] = uigetfile( ...
        {'*.wav;*.mp3;*.mp4', 'Audio/Video Files (*.wav, *.mp3, *.mp4)'}, ...
        'Select an Audio File');
    if isequal(fileName, 0)
        error('לא נבחר קובץ אודיו לעיבוד.');
    end

    fullPath = fullfile(pathName, fileName);
    [~, baseName, ~] = fileparts(fullPath);

    % קריאת האודיו
    [sig, fs] = audioread(fullPath);

    % המרה למונו (במקרה של סטריאו/יותר ערוצים)
    if size(sig, 2) > 1
        sig = mean(sig, 2);
    end
end

function [frames, frameStep, winSize, overlap] = frame_signal(sig, fs)
    windowDuration = 0.03;          % 30 ms
    winSize        = round(windowDuration * fs);
    overlap        = round(0.25 * winSize);
    frameStep      = winSize - overlap;

    totalLength = length(sig);
    numFrames   = floor((totalLength - overlap) / frameStep);

    frames = zeros(winSize, numFrames);

    for i = 1:numFrames
        startIdx     = (i - 1) * frameStep + 1;
        endIdx       = min(startIdx + winSize - 1, totalLength);
        currentFrame = sig(startIdx:endIdx);
        currentFrame = currentFrame .* hamming(length(currentFrame));
        frames(1:length(currentFrame), i) = currentFrame;
    end
end

function [vadBinary, vadTime, frameRMS] = compute_vad(frames, fs, frameStep)
    frameRMS      = sqrt(mean(frames.^2, 1));
    rmsThreshold  = 0.3 * mean(frameRMS);
    vadBinary     = frameRMS > rmsThreshold;
    numFrames     = length(vadBinary);
    vadTime       = (0:numFrames - 1) * (frameStep / fs);
end

function [S, S_db, F, T, pitchValues] = compute_spectrogram_and_pitch(sig, fs, winSize, overlap)
    % STFT
    [S, F, T] = stft(sig, fs, ...
        'Window', hamming(winSize), ...
        'OverlapLength', overlap);

    S_db = mag2db(abs(S));

    % Pitch track (דורש Audio Toolbox)
    pitchValues = pitch(sig, fs, ...
        'WindowLength', winSize, ...
        'OverlapLength', overlap, ...
        'Range', [50, 500]);
end

function synthesizedSignal = synthesize_pseudo_speech(sig, fs, pitchValues, vadBinary, frameStep, winSize)
    totalLength       = length(sig);
    synthesizedSignal = zeros(totalLength, 1);

    numFrames = min(length(vadBinary), length(pitchValues));

    for i = 1:numFrames
        if ~vadBinary(i)
            continue; % רק חלונות עם פעילות קולית
        end

        fundamentalFreq = pitchValues(i);
        if isnan(fundamentalFreq) || fundamentalFreq <= 0
            continue;
        end

        % הרמוניות
        harmonicFreqs = (1:5) * fundamentalFreq;
        harmonicFreqs(harmonicFreqs > fs/2) = [];

        syntheticSpectrum = zeros(winSize, 1);
        for freq = harmonicFreqs
            bin = round(freq / (fs / winSize)) + 1;
            if bin <= winSize
                syntheticSpectrum(bin) = 1;
            end
        end

        % IFFT
        syntheticFrame = real(ifft(syntheticSpectrum, 'symmetric'));

        % שילוב בחזרה לאות
        startIdx = (i - 1) * frameStep + 1;
        endIdx   = min(startIdx + winSize - 1, totalLength);
        L        = endIdx - startIdx + 1;
        synthesizedSignal(startIdx:endIdx) = ...
            synthesizedSignal(startIdx:endIdx) + syntheticFrame(1:L);
    end
end

function baseFrequency = compute_base_frequency_from_spectrum(S, F)
    % חישוב תדר בסיס (תדירות השיא בספקטרום) לכל פריים
    numFrames = size(S, 2);

    % עובדים רק עם תדרים חיוביים
    posIdx = F >= 0;
    F_pos  = F(posIdx);
    S_pos  = abs(S(posIdx, :));

    baseFrequency = NaN(numFrames, 1);

    for i = 1:numFrames
        [~, peakIndex]   = max(S_pos(:, i));   % השיא בספקטרום
        baseFrequency(i) = F_pos(peakIndex);   % התדר המתאים
    end
end

function plot_results(sig, fs, vadBinary, vadTime, S_db, F, T, pitchValues, baseFrequency, synthesizedSignal)
    figure;

    %% 1) Waveform + VAD
    subplot(4,1,1);
    timeAxis = (0:length(sig)-1) / fs;
    plot(timeAxis, sig, 'b');
    hold on;
    Lvad = min(length(vadTime), length(vadBinary));
    stairs(vadTime(1:Lvad), vadBinary(1:Lvad) * max(sig), 'r', 'LineWidth', 1.2);
    title('Waveform with VAD');
    xlabel('Time (s)'); ylabel('Amplitude');

    %% הכנת Pitch מסונן לפי VAD
    numFrames = length(vadBinary);
    Lp  = min(length(pitchValues), numFrames);
    filteredPitch   = pitchValues(1:Lp);
    vadForPitch     = vadBinary(1:Lp);
    filteredPitch(~vadForPitch) = NaN;

    %% סינון תדר הבסיס לפי אותו VAD
    Lb0 = min(length(baseFrequency), numFrames);
    bf  = baseFrequency(1:Lb0);
    Lb  = min(Lb0, Lp);
    bf(~vadForPitch(1:Lb)) = NaN;   % ממסך לפי VAD

    %% 2) Spectrogram (positive freqs) + Pitch + Base F
    subplot(4,1,2);
    posIdx   = F >= 0;
    F_pos    = F(posIdx);
    S_pos_db = S_db(posIdx, :);

    imagesc(T, F_pos, S_pos_db);
    axis xy; colormap jet; colorbar;
    hold on;

    % התאמת אורך הזמן לפיץ' ולתדר הבסיס
    Lcommon = min([length(T), length(filteredPitch), length(bf)]);
    if Lcommon > 0
        plot(T(1:Lcommon), filteredPitch(1:Lcommon), 'g', 'LineWidth', 1.2);
        plot(T(1:Lcommon), bf(1:Lcommon),          'b', 'LineWidth', 1.0);
    end

    title('Spectrogram with Pitch & Base Frequency');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');

    %% 3) Pitch & Base Frequency contour
    subplot(4,1,3);
    Lcommon = min([length(T), length(filteredPitch), length(bf)]);
    if Lcommon > 0
        pitchTime = T(1:Lcommon);
        plot(pitchTime, filteredPitch(1:Lcommon), 'g', 'LineWidth', 1.2); hold on;
        plot(pitchTime, bf(1:Lcommon),           'b', 'LineWidth', 1.2);
    end
    title('Pitch & Base Frequency Contour (VAD only)');
    xlabel('Time (s)'); ylabel('Frequency (Hz)');
    ylim([50, 500]);
    legend('Pitch', 'Base Frequency');

    %% 4) Synthesized signal
    subplot(4,1,4);
    tSynth = (0:length(synthesizedSignal)-1) / fs;
    plot(tSynth, synthesizedSignal, 'm', 'LineWidth', 1.0);
    title('Synthesized Pseudo-Speech Signal');
    xlabel('Time (s)'); ylabel('Amplitude');
end

function export_results(vadTime, vadBinary, T, pitchValues, synthesizedSignal, fs, baseName, pathName)
    % בסיס לשם הקובץ – תשמור ליד קובץ האודיו
    outBase = fullfile(pathName, baseName);

    % VAD results
    Lvad = min(length(vadTime), length(vadBinary));
    T_vad = table(vadTime(1:Lvad)', vadBinary(1:Lvad)', ...
        'VariableNames', {'Time', 'VAD'});
    writetable(T_vad, [outBase '_vad.csv']);

    % Pitch results
    Lp = min(length(T), length(pitchValues));
    T_pitch = table(T(1:Lp)', pitchValues(1:Lp)', ...
        'VariableNames', {'Time', 'PitchFrequency'});
    writetable(T_pitch, [outBase '_pitch.csv']);

    % Synthesized audio
    audiowrite([outBase '_synth.wav'], synthesizedSignal, fs);

    fprintf('תוצאות נשמרו ליד קובץ הקלט:\n%s_synth.wav\n%s_vad.csv\n%s_pitch.csv\n', ...
        outBase, outBase, outBase);
end
