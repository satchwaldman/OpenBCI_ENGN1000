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
board_shim_3.start_stream(45000, '');

% % % 4, 5, 8, 17, 18, 21, 23
% avg_data_4 = zeros(1,129);
% avg_data_5 = zeros(1,129);
% avg_data_8 = zeros(1,129);
% avg_data_17 = zeros(1,129);
% avg_data_18= zeros(1,129);
% avg_data_21 = zeros(1,129);
% avg_data_23 = zeros(1,129);
big_data_array = zeros(25,129);

L = 256;
f = 125 * (0:(L/2))/L;
% for i = 1:5
    % board_shim_3.add_streamer('file://data_default.csv:w', preset_3);
    
pause(15);
board_shim_3.stop_stream();
data_3 = board_shim_3.get_current_board_data(1280, preset_3);
board_shim_3.release_session();

% channel_list = {4, 5, 8, 17, 18, 21, 23};

% row_4 = data_3(4,:);
for row_i = 1:25
    row = data_3(row_i,:);
    for i = 1:5
        partition_i = row((i-1)*256 + 1 : i*256);
        Y = fft(partition_i);
        P2 = abs(Y/L);
        P1 = P2(1:L/2+1);
        P1(2:end-1) = 2*P1(2:end-1);
        big_data_array(row_i,:) = big_data_array(row_i,:) + P1;
    end
end

big_data_array = big_data_array ./ 5;

figure;
for row_i = 1:25
    subplot(5,5,row_i); hold on
    plot(f,big_data_array(row_i,:))
    set(gca, 'YScale', 'log')
end

% writematrix(big_data_array, "eyes_closed_10.csv");

% disp(big_data_array(1,:))








