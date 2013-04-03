function addsignalspaths()
    % Add M-Signals paths to Matlab search paths
    
    d = signalsdir();
    
    p = {
        fullfile(d, 'doc')
        fullfile(d, 'doc', 'examples')
        };
    
    addpath(p{:});
    savepath();
end
