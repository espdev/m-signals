classdef Receiver < handle
    % Class implements signal receiver.
    %
    % Class implements signal receiver functionality.
    % Class is used alongside with the Signal class.
    %
    % Receiver implementation features::
    % - Receiver can be connected to several signals simultaneously.
    % - Receiver can be enabled or disabled to receive signals.
    % - The exception in the callback-function of the receiver does not
    %   stop the signal sending to other
    %   receivers (the described behavior may depend on signal parameters)
    % - User class ErrorHandler shall be defined for exception handling. 
    %
    % Usage::
    % @code
    % signal = signals.Signal();
    % receiver = signals.Receiver(@(varargin) disp('Hello, Receiver!'));
    %
    % signal.connect(receiver)
    % signal.emit()
    % @endcode
    %
    % @sa Signal
    %
    
    % ---------------------------------------------------------------------
    % Project   : M-Signals
    % Version   : 1.0
    % Author    : Evgeny Prilepin
    % Created   : 27.12.11
    % Updated   : 23.01.13
    % Copyright : (C) 2011-2013 Evgeny Prilepin 
    % ---------------------------------------------------------------------

    properties (Access = public)
        
        % Callback function handle
        %
        % Function handle or class method handle is executed 
        % when the signal is emitted to be obtained by a receiver.  
        %
        % @type function_handle
        Callback
        
        % Reference to the instance of the user class ErrorHandler
        % containing the process function called when the exception has
        % occurred in a receiver
        %
        % Property keeps the reference to the class instance inherited from
        % ErrorHandler.
        % If the exception has occurred in a receiver connected to a signal
        % during signal generation, the method "process" of this class is
        % called.
        %
        % "Process" function signature:
        %   process (exception, signal, receiver)
        %
        % Input arguments:
        %   exception -- MException object, containing the information
        %                about an exception
        %   signal    -- The object of the signal that was receiving when
        %                the exception has occurred
        %   receiver  -- The object of the receiver, in which the exception
        %                has occurred
        %
        % @note
        %   If the exception has occurred in ReceiveErrorHandler, the
        %   information about the exception
        %   shall be displayed in the command prompt window. The exception
        %   is not caught at signal level.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % Flag determines whether the receiver is enabled or disabled to
        % receive a signal
        %
        % @type logical @default true
        IsEnabled
        
    end
    
    
    methods
        % Public API methods
        
        function self = Receiver(callback, isEnabled)
            % Constructor
            %
            % Creates Receiver class instance.
            %
            % Usage::
            %   self = Receiver(callback)
            %   self = Receiver(callback, isEnabled)
            %
            % Parameters:
            %   callback:  Handler to function that will be performed when 
            %              signal is emitted @type function_handle
            %   isEnabled: Flag determines whether receiver is enables or
            %              disabled. @type logical @default true 
            %
            
            narginchk(1, 2);
            
            if (nargin < 2)
                isEnabled = true;
            end
            
            validateattributes(callback, {'function_handle'}, {}, 1)
            validateattributes(isEnabled, {'numeric', 'logical'}, {'scalar'}, 2)
            
            self.Callback = callback;
            self.ReceiveErrorHandler = signals.ErrorHandler();
            self.IsEnabled = logical(isEnabled);
        end
        
        function receive(self, signal, varargin)
            % Receives the emitted signal 
            %
            % Method receives a signal and performs a function specified in 
            % Callback if IsEnabled = true.
            %
            % Usage ::
            %   self.receive(signal, varargin)
            %
            % Parameters:
            %   signal: object of the receiving signal 
            %   varargin: arguments of the receiving signal 
            %
            
            if ~self.IsEnabled
                return
            end
            
            try
                inputs = varargin;
                
                if isempty(varargin)
                    self.Callback();
                    return
                end
                
                args = self.getCallbackArgs(varargin{:});
                self.Callback(args{:});
            catch re
                if strcmp(re.identifier, 'MATLAB:maxrhs')
                    % EXCEPTION: "Too many input arguments".
                    % Remove arguments one by one from the end to
                    % call eventually the function with the required number
                    % of arguments.
                    inputs = inputs(1:end-1);
                    self.receive(signal, inputs{:});
                else
                    try
                        self.ReceiveErrorHandler.process(re, signal, self)
                    catch he
                        fprintf(2, ['Error in "ReceiveErrorHandler" in the ', ...
                            'receiver connected to the signal "%s":\n'], ...
                            signal.Name);
                        fprintf(2, '%s\n', he.getReport());
                    end
                    
                    rethrow(re);
                end
            end
        end
        
    end % Public API methods
    
    
    methods (Access = private)
        
        function args = getCallbackArgs(self, varargin)
            % Defines signal arguments that can be transmitted to Callback
            
            args = varargin;
            
            try
                % Error using nargin
                % Unable to ensure a valid workspace for the function ...
                argsMax = nargin(self.Callback);
            catch e %#ok<NASGU>
                argsMax = -1;
            end
            
            if (argsMax == 0)
                % Callback does not receive arguments
                args = {};
                
            elseif (argsMax < 0)
                % Callback receives varargin
                return
                
            elseif (argsMax > 0)
                % Callback receives the definite number of arguments
                args = args(1:min(numel(args), argsMax));
            end
        end
        
    end % Private Methods
    
    
    methods
        
        function set.Callback(self, val)
            validateattributes(val, {'function_handle'}, {})
            self.Callback = val;
        end
        
        function set.IsEnabled(self, val)
            validateattributes(val, {'numeric', 'logical'}, {'scalar'})
            self.IsEnabled = logical(val);
        end
        
        function set.ReceiveErrorHandler(self, val)
            validateattributes(val, {'signals.ErrorHandler'}, {'scalar'})
            self.ReceiveErrorHandler = val;
        end
        
    end % Properties Getters/Setters
    
end % signals.Receiver
