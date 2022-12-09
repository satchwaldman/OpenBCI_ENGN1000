%% Setup
addpath('matlab_package')
addpath('matlab_package/brainflow')
addpath('matlab_package/brainflow/lib')
addpath('matlab_package/brainflow/inc')

BoardShim.set_log_file('brainflow.log');
BoardShim.enable_dev_board_logger();

params_3 = BrainFlowInputParams();
params_3.serial_port = '/dev/cu.usbserial-DM0258CC';
board_shim_3 = BoardShim(int32(BoardIds.CYTON_DAISY_BOARD), params_3);
preset_3 = int32(BrainFlowPresets.DEFAULT_PRESET);
sampling_rate_3 = BoardShim.get_sampling_rate(int32(BoardIds.CYTON_DAISY_BOARD), preset_3);
board_shim_3.prepare_session();

% board_shim_3.add_streamer('file://data_default.csv:w', preset_3);
board_shim_3.start_stream(45000, '');
pause(4);
board_shim_3.stop_stream();
data_3 = board_shim_3.get_current_board_data(256, preset_3);
%disp(data_3);
board_shim_3.release_session();



% single_channel_data = data_3(2,:);
% t = 1:length(single_channel_data);
% % disp(size(t))
% % disp(size(single_channel_data))
% 
% figure;
% plot(t, single_channel_data);
figure;
channel_list = {4, 5, 8, 17, 18, 21, 23};
% channel_list = {4};
n_channels = 16;
for i_ch = 1:length(channel_list)
    subplot(4,2,i_ch); hold on
    plot(data_3(channel_list{i_ch},:))
end

figure;
plot(data_3(4,:))

figure;
% for i_ch = 1:length(channel_list)
%     subplot(4,2,i_ch); hold on
%     L = 256; %%data_3(i_ch);
%     NFFT = 2^nextpow2(L);
%     fft_data_row = fft(data_3(channel_list{i_ch},:), NFFT) / L;
% %     Fv = linspace(0, 1, NFFT/2 + 1) * sampling_rate_3 / 2;
%     f = sampling_rate_3*(0:(L/2))/L;
% 
%     plot(f, abs(fft_data_row) * 2)
% %     xlim([0 100]);
% end


% L = 256; %%data_3(i_ch);
% NFFT = 2^nextpow2(L);
% fft_data_row = fft(data_3(channel_list{1},:), NFFT) / L;
% % Fv = linspace(0, 1, NFFT/2 + 1) * sampling_rate_3 / 2;
% f = sampling_rate_3.*(0:(L/2))./L;
% 
% plot(f, abs(fft_data_row) * 2)

Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 256;             % Length of signal
t = (0:L-1)*T;        % Time vector

S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);

X = S + 2*randn(size(t));

plot(1000*t(1:50),X(1:50))
% title("Signal Corrupted with Zero-Mean Random Noise")
% xlabel("t (milliseconds)")
% ylabel("X(t)")

row_1 = data_3(4,:);
Y = fft(row_1);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 125 * (0:(L/2))/L;

plot(f,P1) 
% title("Single-Sided Amplitude Spectrum of X(t)")
% xlabel("f (Hz)")
% ylabel("|P1(f)|")
set(gca, 'YScale', 'log')

% Gamma greater than 30(Hz) BETA (13-30Hz), ALPHA (8-12 Hz), THETA (4-8 Hz), and DELTA(less than 4 Hz)
norm = sum(P1);

gamma_integral = sum(P1(31:end))/norm;
beta_integral = sum(P1(13:31))/norm;
alpha_integral = sum(P1(8:13))/norm;
theta_integral = sum(P1(4:8))/norm;
delta_integral = sum(P1(2:4))/norm;

total_int = alpha_integral + beta_integral + gamma_integral + delta_integral + theta_integral;

int_alpha = 100 * alpha_integral / total_int;
int_beta = 100 * beta_integral / total_int;
int_delta = 100 * delta_integral / total_int;
int_gamma = 100 * gamma_integral / total_int;
int_theta = 100 * theta_integral / total_int;



% figure;
% plot(t, single_channel_data)
% plot(t, transpose(data_3))

% disp(size(t))
% disp(size(data_3))

% figure;
% plot(t, data_3(1))




%% FFT

% eeg_channels_3 = BoardShim.get_eeg_channels(int32(BoardIds.CYTON_DAISY_BOARD), preset_3);
% % wavelet for first eeg channel %
% fft_data_matrix_3 = [];
% figure;
% for i_ch = 1:length(eeg_channels_3)
%     first_eeg_channel_3 = eeg_channels_3(i_ch);
%     original_data_3 = data_3(first_eeg_channel_3, :);
%     fft_data_3 = DataFilter.perform_fft(original_data_3, int32(WindowOperations.NO_WINDOW));
%     subplot(4,4,i_ch); hold on
%     fft_data_matrix_3 = [fft_data_matrix_3, fft_data_3];
%     plot(fft_data_3)
% %     restored_fft_data_3 = DataFilter.perform_ifft(fft_data_3);
% end
% % fft for first eeg channel %
% 
% % filtered_data = DataFilter.perform_lowpass(original_data_3, sampling_rate_3, 50.0, 3, int32(FilterTypes.BUTTERWORTH), 0.0);
% 
% % t_129 = 0:1.0:128;
% % t_256 = 1:1.0:256;
% % 
% % figure;
% % plot(t_129, fft_data_3);
% % figure;
% % plot(t_256, restored_fft_data_3)
% % size(t);
% % size(fft_data_3);
% % 
% 
% 
% % figure;
% % n_channels = 16;
% % for i_ch = 2:n_channels
% %     subplot(4,4,i_ch); hold on
% %     plot(fft_data_3(i_ch,:))
% % end
% 
% % channel_list = {4, 5, 8, 17, 18, 21, 23};
% % n_channels = 16;
% % for i_ch = 1:length(channel_list)
% %     subplot(4,2,i_ch); hold on
% %     plot(fft_data_3(channel_list{i_ch},:))
% % end




