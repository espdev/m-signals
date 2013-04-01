classdef Receiver < handle
    % ����� ��������� ������� ��������
    %
    % ����� ��������� ���������������� �������� ��������.
    % ���� ����� ������������ ��������� � ������� Signal.
    %
    % ����������� ���������� ��������::
    % - ������� ����� ���� ��������� � ���������� �������� ������������.
    % - ������� ����� ���� ������� � �������� ��� ����� ��������
	% - ���������� � callback-������� �������� �� ������������� �������� 
    %   ������� ������ ��������� (��������� ����� �������� �� ���������� �������)
    % - � �������� ����� ���� ��������� �������-handler ��� ��������� ����������
    %
    % �������������::
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
    %   ������    : M-Signals
    %   ������    : 1.0
    %   �����     : ������� ��������
    %   �������   : 27.12.11
    %   ��������� : 23.01.13
    %
    %   Copyright : (C) 2011-2013 ������� ��������
    % ---------------------------------------------------------------------
    
    properties (Access = public)
        
        % ��������� �� callback-�������
        %
        % ��������� �� ������� ��� ����� ������, ������� ����� �������� ���
        % ���������� �������, ������� ��������� �������.
        %
        % @type function_handle
        Callback
        
        % Callback-�������, ���������� ��� ������������� ���������� � ������ ��������
        %
        % ������ ������ �� ��������� ������, ������������ �� ErrorHandler. 
        % ����� � ��������, ������������ � ���������� �������, ��������� 
        % ���������� ��� ��������� �������, ����� ������ ����� process ����� ������.
        %
        % ��������� ������� process:
        %   process(exception, signal, receiver)
        %
        % ������� ���������:
        %   exception -- ������ MExceptions � ����������� �� ����������
        %   signal    -- ������ �������, ������� ���������� � ������ ������������� ����������
        %   receiver  -- ������ ��������, � ������� ��������� ����������
        %
        % @note
        %   ���� � ReceiveErrorHandler ���������� ����������, �� ���������� �
        %   ��� ��������� � ��������� ����, �� ��� �� ��������������� �� ������ �������.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % ���� ����������, ������� �� ������ ������� �� ��������� �������
        %
        % @type logical @default true
        IsEnabled
        
    end
    
    
    methods
        % Public API methods
        
        function self = Receiver(callback, isEnabled)
            % �����������
            %
            % ������ ��������� ������ Receiver.
            %
            % �������������::
            %   self = Receiver(callback)
            %   self = Receiver(callback, isEnabled)
            %
            % Parameters:
            %   callback: ��������� �� �������, ������� ����� ��������� 
            %             ��� ���������� ������� @type function_handle
            %   isEnabled: ���� ����������, ������� �� �������. @type logical @default true
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
            % ��������� ���������� ������
            %
            % ����� ��������� ������ � ��������� �������, �������� � 
            % Callback ���� IsEnabled = true.
            %
            % �������������::
            %   self.receive(signal, varargin)
            %
            % Parameters:
            %   signal -- ������ ������������ �������
            %   varargin -- ��������� ������������ �������
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
                    % ������� �� ������ ��������� � �����, ����� � �����
                    % ������� ������� � ��������� ����������� ����������.
                    inputs = inputs(1:end-1);
                    self.receive(signal, inputs{:});
                else
                    try
                        self.ReceiveErrorHandler.process(re, signal, self)
                    catch he
                        fprintf(2, ['Error in "ReceiveErrorHandler" in the ', ...
                            'receiver connected with the signal "%s":\n'], ...
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
            % ���������� ��������� �������, ������� ����� ���� �������� � Callback
            
            args = varargin;
            
            try
                % Error using nargin
                % Unable to ensure a valid workspace for the function ...
                argsMax = nargin(self.Callback);
            catch e %#ok<NASGU>
                argsMax = -1;
            end
            
            if (argsMax == 0)
                % Callback �� ��������� ����������
                args = {};
                
            elseif (argsMax < 0)
                % Callback ��������� varargin
                return
                
            elseif (argsMax > 0)
                % Callback ��������� ����������� ���. ����������
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

