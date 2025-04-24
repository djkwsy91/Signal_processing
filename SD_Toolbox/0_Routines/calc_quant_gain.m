% calc_quant_gain  - estimate gain

quant_input = reshape(Qin,[],1);
quant_output = reshape(Qout,[],1);

if(size(quant_input) ~= size(quant_output))
    warning('calc_quant_gain', 'Input and output samples do not match');
end

mean(quant_input.*quant_output)/mean(quant_input.*quant_input)	% Compute effective gain