numParts = 2;
numbus = 2;

rectStates = [1 0;
              0.75 0.6;
              0 1;
              0.25 0.4]            

[polarStates] = convertRect2Polar(rectStates, numParts, numbus)
    
    
