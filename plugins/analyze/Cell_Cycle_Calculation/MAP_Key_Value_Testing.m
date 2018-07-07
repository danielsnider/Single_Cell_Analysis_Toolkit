keySet = reshape(data_legend_platemap, [size(cc_Interest,1)*size(cc_Interest,2) 1])
valueSet = reshape(cc_Interest, [size(cc_Interest,1)*size(cc_Interest,2) 1])
M = containers.Map(keySet,valueSet)
M(char(keySet(1)))

keySet = {'Hi', 'Bye'};
value = {[1010 1010 1020], [000 000 000]}
M = containers.Map(keySet,value)

