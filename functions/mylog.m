function [out] = mylog(in)

% mylog takes vector "in", sets all negative or zero values to minimum 
% positive value and evaluates log.

Input=in;
srt=sort(Input);
MinLevel=srt(find(srt>0,1,'first'));
Input(Input<=0)=MinLevel;
out=log(Input);