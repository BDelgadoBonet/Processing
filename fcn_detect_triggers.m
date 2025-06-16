function [idx_triggers, triggers] = fcn_detect_triggers(x, verbose)
%FCN_DETECT_TRIGGERS Detect triggers in a signal.
%   Given a signal: transform it to the positives by squaring, identify
%   peaks taking the derivative (but choose only the highest derivatives), 
%   then detect peaks from the processed signal with MATLAB build-in 
%   function <findpeaks>. Plot to confirm results.
%
%   :param x: signal from which to detect triggers (<nsamples>x1 single)
%   :param verbose: verbosity, 1=silent, 2=print progress, 3=plot output.
%
%   :return: 
%       1- indices for triggers within signal (<ntriggers>x1 double)
%       2- binary signal, where trigger==1 (<nsamples>x1 single)
%
% Created by Blanca Delgado (bdelgado@unizar.es)
% April 2024, last edit: 2024-05-09

x2 = x.^2;  % squared to consider only positive values
dx = x2(2:end) - x2(1:end-1);  % derivative to detect onset of trigger
dx(dx < max(dx)/2) = 0;  % consider only upper half
[~, idx_triggers] = findpeaks(dx);  % finally, detect peaks

triggers = zeros(size(x));
triggers(idx_triggers) = 1;
triggers = single(triggers);

if verbose==1
    fprintf("- DETECTED TRIGGERS: %i\n", sum(triggers))
elseif verbose ==2
    figure, hold on
    plot(x)
    plot(find(triggers == 1), triggers(triggers == 1) * max(x), 'or');
    title("Input signal with detected triggers", int2str(sum(triggers)))
    ylim([min(x)-0.2, max(x)+0.2])
end
end