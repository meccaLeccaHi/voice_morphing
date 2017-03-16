function NOISE_OUT = SSN(SIGNAL_IN)
% function to make speech-shaped noise
%
% last modified 03-09-17
% apj

% apply the fourier transform and randomize the phases of all the spectral components
SPECT_COMP                     = abs(fft(SIGNAL_IN)).*...
    exp(1i*2*pi*rand(size(SIGNAL_IN)));
NOISE_OUT                     = real(ifft(SPECT_COMP)); % Obatining the real parts of the IFFT
end