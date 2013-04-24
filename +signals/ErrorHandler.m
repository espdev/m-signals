classdef ErrorHandler < handle
    % Exception handling in signals and receivers
    %
    % Class contains method "process" for exception handling in signals and
    % receivers.
    %
    % Method "process" does nothing, by default. Method "process"
    % shall be redefined in the inherited user class.
    %
    
    % ---------------------------------------------------------------------
    % Project    : M-Signals
    % Version    : 1.0
    % Author     : Evgeny Prilepin 
    % Created    : 31.03.11
    % Updated    : 31.03.13
    %
    % Copyright : (C) 2011-2013 Evgeny Prilepin 
    % ---------------------------------------------------------------------
    
    
    methods (Access = {?signals.Signal, ?signals.Receiver})
        
        function process(self, exception, signal, receiver) %#ok<INUSD>
            % Handles an exception in the signal and receiver 
            %
            % The exception occurred during the signal generation, the 
            % method is called.
            %
            % Usage::
            % @code
            % errorHandler.process(exception, signal, receiver)
            % @endcode
            %
            % Parameters:
            %   exception: Exception object. Instance MException
            %   signal:    Signal object. The generation of a signal
            %              object has led to the exception occurred in the
            %              receiver
            %   receiver:  Receiver object. The exception has occurred in
            %              the receiver object
            %

            
        end
        
    end
    
end % ErrorHandler
