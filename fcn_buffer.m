function y_buffer = fcn_buffer(y_signal, y_triggers, fs, fs_out, t_total, t_trigger, verbose)
%FCN_BUFFER Split signal in trials according to triggers.
%   Using one channel, all triggers are automatically detected. For each 
%   trigger, a trial is defined as the interval [trigger-t_trigger,
%   t_total-(trigger-t_trigger)]. If original sampling frequency (fs) and
%   output sampling frequency (fs_out) are different, all trials are
%   interpolated to the new sampling frequency.
%
%   :param y_signal: signals to be split (<nsamples>x<nchannels>).
%   :param y_triggers: signal with triggers (<nsamples>x1).
%   :param fs: sampling frequency for original signal.
%   :param fs_out: sampling frequency for output buffer.
%   :param t_total: total lenght of trial length [ms].
%   :param t_trigger: onset of trigger, within trial [ms].
%   :param verbose: verbosity, 1=silent, 2=print progress, 3=plot output.
%
%   :return: split signal (<nsamples>x<nchannels>x<ntrials>), where the
%   number of trials is indicated by the number of detected triggers.
%
% MAT files: 
%   fcn_detect_triggers (detect triggers in a signal).
%
% Created by Blanca Delgado Bonet (bdelgado@unizar.es)
% April 2024, last edit: 2024-05-15

%% Detect triggers:
[idx_triggers, ~] = fcn_detect_triggers(y_triggers, verbose);

if length(idx_triggers) > 1000
    warning("Detected triggers exceeds maximum preference; data cannot be buffered.")
    y_buffer = [0, 0, 0];
    return
end

%% Split signal by triggers (samples x channels x trials):
s_total = round(t_total / 1000 * fs);
s_before = round(t_trigger / 1000 * fs);
s_after = s_total - s_before;

y_buffer = zeros(s_total, size(y_signal, 2), length(idx_triggers));
for i_trigger=1:length(idx_triggers)

    s = idx_triggers(i_trigger);
    y_buffer(:, :, i_trigger) = y_signal(s-s_before:s+s_after-1, :);
end

%% Interpolate to new sampling frequency:
if fs~=fs_out
    N_in = size(y_buffer, 1);                  % original samples
    t_in = (0:N_in-1)/fs;                      % original time
    
    t_out = 0:1/fs_out:t_total/1000-1/fs_out;  % interpolated time
    N_out = length(t_out);                     % interpolated samples

    nchannels = size(y_buffer, 2);
    ntrials = size(y_buffer, 3);

    y_buffer_out = zeros(N_out, nchannels, ntrials);
    for i_trial=1:ntrials
        for i_channel=1:nchannels
            y_i_in = y_buffer(:, i_channel, i_trial);
            y_i_out = interp1(t_in, y_i_in, t_out, 'spline');
            y_buffer_out(:, i_channel, i_trial) = y_i_out;
        end
    end
    y_buffer = y_buffer_out;  % update output variable
end


%% Report:
if verbose==1
    fprintf('- SIGNAL BUFFERED: [%s] to [%s]\n', num2str(size(y_signal)), num2str(size(y_buffer)));
    
    if fs~=fs_out
        fprintf('- SIGNAL INTERPOLATED: fs=%f to fs=%f\n', fs, fs_out)
    end
elseif verbose==2
end

end
