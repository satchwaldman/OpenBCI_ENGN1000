% addpath('NeuroPi/')
addpath('matlab_package')
addpath('matlab_package/brainflow')
addpath('matlab_package/brainflow/lib')
addpath('matlab_package/brainflow/inc')

BoardShim.set_log_file('brainflow.log');
BoardShim.enable_dev_board_logger();

params = BrainFlowInputParams();
params.serial_port = '/dev/cu';

recording_time = 600; %s -- 10 min

board_shim = BoardShim(int32(BoardIds.SYNTHETIC_BOARD), params);
% board_shim.board_id = 2;
preset = int32(BrainFlowPresets.DEFAULT_PRESET);
eeg_channels = BoardShim.get_eeg_channels(int32(BoardIds.SYNTHETIC_BOARD), preset);
sampling_rate = BoardShim.get_sampling_rate(int32(BoardIds.SYNTHETIC_BOARD), preset);

n_samples = sampling_rate*recording_time;
n_channels = length(eeg_channels);

figure;
% initialize session and collect data for specified amount of time
board_shim.prepare_session();
board_shim.add_streamer('file://data_default.csv:w', preset);
board_shim.start_stream(45000, ''); %is this buffer size???
pause(18)
board_shim.stop_stream();

% read raw data from board
%sampling_rate = BoardShim.get_sampling_rate(int32(BoardIds.SYNTHETIC_BOARD), preset);
%%data = board_shim.get_current_board_data(sampling_rate*recording_time, preset);
data = board_shim.get_board_data(sampling_rate*recording_time, preset);
board_shim.release_session();

original_data = data(eeg_channels, :);
filtered_data = DataFilter.perform_lowpass(original_data, sampling_rate, 20.0, 3, int32(FilterTypes.BUTTERWORTH), 0.0);

if length(filtered_data) < n_samples
    filtered_data = [filtered_data nan(n_channels,n_samples - length(filtered_data))];
end
%all_data{i_trial} = filtered_data;
all_data = filtered_data;

for i_ch = 1:n_channels
    subplot(4,4,i_ch); hold on
    plot(filtered_data(i_ch,:),'color',[0.6,0.6,0.6])
end
drawnow
sgtitle("Trial " + string(i_trial))

for i_ch = 1:n_channels
    subplot(4,4,i_ch); hold on
    %plot(fft(filtered_data(i_ch,:)),'r','LineWidth',3)
    plot(filtered_data(i_ch,:),'r','LineWidth',3)
    xline(blink_frac*recording_time)
end