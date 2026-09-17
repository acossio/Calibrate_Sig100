function [output] = complexSaturate(input, maxVal, minVal)
    
    R = real(input);
    index = find(R > maxVal);
    R(index) = maxVal;
    
    index = find(R < minVal);
    R(index) = minVal;
    
    
    I = imag(input);
    index = find(I > maxVal);
    I(index) = maxVal;
    
    index = find(I < minVal);
    I(index) = minVal;
    
    output = complex(R,I);
