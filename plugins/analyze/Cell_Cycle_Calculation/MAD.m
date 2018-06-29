function [Y]=MAD(X)
Y=median(abs(X-median(X)));