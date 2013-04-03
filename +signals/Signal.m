classdef Signal < handle
    % ����� ��������� ������
    %
    % ����� ��������� ���������������� �������.
    % �������� �������� ��������� ������ �������������� "Observer".
    % ������� ������� �������� (events), �� ����� ������ � ������������� � 
    % ������������� ������ �������. ������������� ��������� �������� ������� 
    % ��������� �������� � ������ � �++ ���������� Qt.
    %
    % ����������� ���������� ��������::
    % - ������� ����������� � ����������
    % - ������� ����� ���� ��������� � ������� ��������� ��� ��������
    %   �� ������� ��������
    % - ��������� ������� ����� ���� �������������� ����������
    % - ������� ��������� ���������� ����� ���������� ����������
    % - ����������� ����� ���� ������ ������������ ��������� � ���� 
    %   ������������ ����������.
    % - ������� ����� ����� ��� �� ����� �����������.
    % - ���� ������ �� ����� �����������, ����� ������ ��������� ���������
    % - ������ ����� ���� ������ ��� ���������, � ����� �������� �����������
    % - ����������� ����� ���� ������ � ����� ������
    % - ����������� ������� ����� ���� ������ ����������� ������ Sender
    % - ��� ��������� �����������, ������ ������������ ���� � ����������� � 
    %   ������� ��� �������
    % - ������ ����� ���������� �� �����������, ����� ���� ������� ���� � �����������
    % - ����������� ��� ����� ������� ����� ������
    % - ��� �������� ������������, ������ ������� ������������
    % - ������ ����� ���� ������������ ������������ ���� ����� ���
    %
    % ��������� ���������� � ���������::
    % ������� ������������ ����������, ������� ����� ��������� � callback-��������
    % ������������ ���������. ��� ������������� ���������� � ��������, ������
    % �� ��������� �������� �� ���� ���������� � ����������� �� ������, �
    % ��� �� �������� �������-���������� ������, ������� ����� ���� ������
    % �������������. ��� ������������� ���������� � ����� �� ���������, ������
    % ���������� ���������� ��� ��������� ������� ����������.
    %
    % �������������::
    % @code
    % % �������� ���������� ������� � ������ ����������� �����������
    % signal = signals.Signal()
    %
    % % ����������� ������� � �������� (�������� ������ ��������)
    % receiver = signal.connect(@(x) fprintf('Hello, %s\n', x))
    % signal.emit('World')
    % @endcode
    %
    % @sa
    % Receiver, Sender
    %
    
    % ---------------------------------------------------------------------
    %   ������    : M-Signals
    %   ������    : 1.0
    %   �����     : ������� ��������
    %   �������   : 27.12.11
    %   ��������� : 31.03.13
    %
    %   Copyright : (C) 2011-2013 ������� ��������
    % ---------------------------------------------------------------------
    
    
    properties (GetAccess = public, SetAccess = private)
        
        % ����������� ������� �������
        %
        % ������, ������� �������� ������������ �������. ���� �� ������,
        % ������ �������� ���������.
        %
        % @type Sender @default empty
        Sender
        
    end
    
    properties (Dependent)
        
        % ��� �������
        %
        % ���, c ������� ������ ��������������� � �����������
        % �� ���� �������� ������ ����, ������� ������ ������ ������� �
        % ������� �����������.
        % ���� ������ ���������, �� Name = "@Anonymous"
        %
        % @type char @default empty
        Name = ''
        
    end
    
    properties (Access = public)
 
        % �������� �������
        %
        % ������ �������� �������. 
        % �������� ����� ���� ������ �������������.
        %
        % @type char @default empty
        Description = ''
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        % ��������� ������� (������)
        %
        % ������ � ��������� ������������ ���������� ������� � �� �����
        %
        % @type char
        Arguments
        
        % ��������, ���������� � ������ ��������
        %
        % ������ ���������, ������� ���������� � ������� �������
        %
        % @type Receiver
        Receivers
        
    end
    
    properties (Access = public)
        
        % ���������� ������ ��� ������������� ���������� � ���������
        %
        % ������ ������ �� ��������� ������, ������������ �� ErrorHandler. 
        % ����� � ����� ��������, ������������ � ������� �������, ��������� 
        % ����������, ����� ������ ����� process ����� ������.
        %
        % ��������� ������� process:
        %   process(exception, signal, receiver)
        %
        % ������� ���������:
        %   exception -- ������ MExceptions � ����������� �� ����������
        %   signal    -- ������ �������
        %   receiver  -- ������ ��������, � ������� ��������� ����������
        %
        % @note
        %   ���� � ReceiveErrorHandler ���������� ����������, �� ����������
        %   �������� ������� ����������� � �������������� ���������.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % ���� ���������, ����� �� ������������ ��������� �� ������� � ���������
        %
        % ���� ������ ���� ���������� � true, �� ��� ������, ����������� �
        % ��������� ����� ������������ � ��������� ����.
        %
        % @note
        %   ���� ����� �� ������ �� ���������� ReceiveErrorHandler, �������
        %   ������ ���������� ��� ������� � ��������.
        %
        % @type logical @default true
        IsEnabledDisplayReceiveErrors = true
        
        % ���� ����������, ����� �� ������ ���������� �������� ���
        % ������������� ������� ������� (Events)
        %
        % ���� ������ ���� ���������� � true, �� ������ ����� ����������
        % ������ ������� ������� ������� �������, � �� ����� ���������
        % ������� Emit.
        %
        % @type logical @default false
        IsDirectEmit = false
        
    end
    
    properties (Dependent)
        
        % ���� ��������� ��������� ������� ���/����
        %
        % ���� �������� ����� true, �� ���������� �������� ����� ��� ���������,
        % ���� �������� ����� false, �� ���������� �������� �� ����� ��� ���������.
        %
        % @type logical @default true
        IsEnabled
        
    end
    
    properties (Access = private)
        
        proxyListener
        signalBlockedListener
        signalUnblockedListener
        senderProp
        emitData = {}
        argsCount = 0
        argsClasses
        isBlockSignal = false
        
    end
    
    properties (Dependent, Access = private)
        
        isAnonymous
        
    end
    
    
    methods
        
        function self = Signal(varargin)
            % �����������
            %
            % ������ ��������� �������.
            %
            % �������������::
            % @code
            % signal = Signal()
            % signal = Signal(sender)
            % signal = Signal(sender, name)
            % signal = Signal(argTypes1, argTypes2, ...)
            % signal = Signal(sender, argTypes1, argTypes2, ...)
            % signal = Signal(sender, name, argTypes1, argTypes2, ...)
            % @endcode
            %
            % Parameters:
            %   sender: ������ ����������� @type Sender
            %   name: ��� �������, ������� ����� ��������� ��� property � sender @type char
            %   argTypes: ���� ������������ ���������� ������� @type cell
            %
            
            narginchk(0, Inf)
            
            argsNum = 0;
            sender = [];
            name = [];
            
            self.Receivers = signals.Receiver.empty();
            self.ReceiveErrorHandler = signals.ErrorHandler();
            
            if (nargin > 0)
                if ~iscell(varargin{1})
                    sender = varargin{1};
                    argsNum = argsNum + 1;
                    
                    if (nargin > 1)
                        if ischar(varargin{2})
                            name = varargin{2};
                            argsNum = argsNum + 1;
                        end
                    end
                end
            end
            
            if ~isempty(sender)
                self.setSender(sender, name);
            end
            
            if (argsNum > 0)
                varargin(1:argsNum) = [];
            end
            
            self.setRequiredArgs(varargin{:})
            self.proxyListener = addlistener(self, 'Emit', @(src,ed) self.emitProxy());
        end
        
        function setSender(self, sender, name)
            % ������������� ��� ������� �����������
            %
            % ����� ����� ������� �����������. ���� ������ ��� ����� 
            % �����������, �� ����� ����� �� �����������, �.�. ������ ��
            % ����� ����� ���������� ������������.
            % ���� ������ ���������� ������� ���, ������ ����� ��������
            % � ������ ����������� ��� ������������ ���� � ������ name.
            %
            % �������������::
            % @code
            % obj.setSender(sender, name)
            % obj.setSender(sender)
            % @endcode
            %
            % Parameters:
            %   sender: ������ �����������. ������ ������������� �� Sender
            %   name: ��� ���� � ������� �����������, � ������� ����� �������� ������
            %
            % @sa removeSender
            %
            
            narginchk(2, 3)
            
            if (nargin < 3)
                name = [];
            end
            
            validateattributes(sender, {'signals.Sender'}, {}, 1)
            
            if ~isempty(name)
                validateattributes(name, {'char'}, {'row'}, 2)
                
                if ~isvarname(name)
                    error('signals:signame', ...
                        'Signal name must be a valid VARNAME.')
                end
            end
            
            self.removeSender();
            self.Sender = sender;
            
            self.signalBlockedListener = addlistener(sender, 'SignalsBlocked', @(varargin)self.blockSignal(true));
            self.signalUnblockedListener = addlistener(sender, 'SignalsUnblocked', @(varargin)self.blockSignal(false));
            
            if ~isempty(name)
                % ���� ������� ��� �������, �� ������������ ������ � �����������
                prop = sender.findprop(name);
                
                if isempty(prop)
                    % ���� ���� ���, ��������� � ������������� � ��� 
                    % �������� ������.
                    self.senderProp = sender.addprop(name);
                    sender.(name) = self;
                else
                    % ���� ���� ��� ����, �� ���������� ���������� ���� ���
                    % ���� �� �������� ����� ��������. ������ ���������
                    % ������� � ������� ��� ������������ ����� � �������.
                    tf = eq(sender.(name), self);
                    
                    if (isempty(tf) || eq(tf, false))
                        error('signals:signalCreateFailed', ...
                            ['Unable to create signal with name "%s". ', ...
                            'This name already exist in Sender "%s".'], ...
                            name, class(sender));
                    else
                        self.senderProp = prop;
                    end
                end
            end
        end
        
        function removeSender(self)
            % ������� ������ � �����������
            %
            % ����� ������� ������ �� ������ � �������� �����������.
            % ��� �������� ������ ������ ���������.
            %
            % �������������::
            % @code
            % obj.removeSender()
            % @endcode
            %
            % @sa setSender
            %
            
            if self.isAnonymous
                return
            end
            
            self.Sender = [];
            
            delete(self.senderProp)
            delete(self.signalBlockedListener)
            delete(self.signalUnblockedListener)
        end
        
        function setRequiredArgs(self, varargin)
            % ������������� ���������� � ���� ������������ ���������� �������
            %
            % ����� ������������� ���������� � ��� ������������ ����������,
            % ������� ����� �������� ��� ���������� �������.
            %
            % �������������::
            % @code
            %   % ������ ����� ����������� � ����� ����������� ���������� ������ ����
            %   self.setRequiredArgs()
            %
            %   % ������ ����� ����������� � �������� ����������� ���������� ��������� ����
            %   self.setRequiredArgs(typeArg1, typeArg2, ..., typeArgN)
            %
            %   % ������ ����� ����������� � �������� ����������� ���������� ������ �� ������������� �����
            %   self.setRequiredArgs({type1Arg1, type2Arg1, ..., typeNArg1}, ...)
            %
            %   % ������ ����� ����������� � �������� ����������� ���������� ������ ����
            %   self.setRequiredArgs({}, {}, ..., {})
            %
            %   % ������ ����� ����������� � ����� ����������� ���������� ������ ����, ��������� ����� ������������
            %   self.setRequiredArgs(..., varargin)
            % @endcode
            %
            % �������::
            % @code
            %   signal.setRequiredArgs()
            %   signal.setRequiredArgs('numeric')
            %   signal.setRequiredArgs({}, 'char')
            %   signal.setRequiredArgs('numeric', 'char')
            %   signal.setRequiredArgs('numeric', 'char')
            %   signal.setRequiredArgs({'char', 'numeric'}, {})
            % @endcode
            %
            
            s = 'Signal(%s)';
            
            if (nargin == 1)
                self.argsCount = 0;
                self.argsClasses = {};
                self.Arguments = sprintf(s, 'varargin');
                return
            end
            
            self.argsCount = numel(varargin);
            self.argsClasses = cell(self.argsCount, 1);
            
            sign = '';
            
            for i = 1:self.argsCount
                classes = varargin{i};
                
                if ~isempty(classes)
                    if ~iscell(classes)
                        classes = {classes};
                    end
                    classes = classes(:).';
                    
                    if ~iscellstr(classes)
                        error('EventSignal:argsClasses', 'Classes must be a char')
                    end
                    
                    sign = [sign, '{', sprintf('''%s'' ', classes{:}), '}, ']; %#ok<*AGROW>
                else
                    sign = [sign, '{}, '];
                end
                
                self.argsClasses{i} = classes;
            end
            
            sign = regexprep(sign, ' }', '}');
            sign = [sign, 'varargin'];
            
            self.Arguments = sprintf(s, sign);
        end
        
        function emit(self, varargin)
            % ��������� ������
            %
            % ����� ��������� ������ � ��������� �����������.
            % ���������� � ��� ���������� ������� �� ��������� �������.
            % @n
            % ��� �������� �������, ������� ��������, (callback-�������) 
            % ����� �������.
            % 
            % �������������::
            % @code
            % self.emit()
            % self.emit(...)
            % @endcode
            %
            % @sa connect
            %
            
            self.emitData = varargin;
            
            if ~self.isBlockSignal
                if self.IsDirectEmit
                    self.emitProxy()
                else
                    notify(self, 'Emit')
                end
            end
        end
        
        function varargout = connect(self, receiverOrCallback, isEnabled)
            % ���������� ������� � �������
            %
            % ����� ���������� ������� � ������� �������.
            % ���� � �������� �������� ��������� ������ callback-������� ���
            % ������, �� ����� ������ ����� �������, ���� ����� ������ ��������,
            % ����� ��������� ��� � ������ ������������ ��������� ���� ���
            % ��� ��� ���.
            %
            % @warning
            % ���� ������ ����������� � ������ ��������, ��� ������� ������
            % ���� ����������� �� ����� ����������, �.�. � ��� ������ ����
            % ���������� ���������, ����� ���������� ������������� ������� 
            % ���������� � �������.
            %
            % �������������::
            % @code
            %   self.connect(receiver)
            %   self.connect(callback)
            %   self.connect(callback, isEnabled)
            %   self.connect(signal)
            %   self.connect(signal, isEnabled)
            %   receiver = self.connect(...)
            % @endcode
            %
            % Parameters:
            % receiver:  ������ ��� ���������� ��������. @type Receiver
            % callback:  ��������� �� �������, ������� ����� 
            %            ���������� ��� ���������� ������� @type function_handle
            % signal:    ������ ������� �������, ������� ����� ����������
            %            ������, ���������� ���� ��������.
            % isEnabled: ���� ���������, ����� �� ������� �������� ��� �����������.
            %            ����� ���� ������ ���� � �������� ������� ��������� ���������
            %            callback-�������. @type logical @default true
            %
            % Return values:
            % receiver: ������ �� ������ ���������� �������� @type Receiver
            %
            % @sa disconnect, emit
            %
            
            narginchk(2, 3)
            nargoutchk(0, 1)
            
            if (nargin < 3)
                isEnabled = true;
            end
            
            validateattributes(receiverOrCallback, ...
                {'signals.Receiver', 'signals.Signal', 'function_handle'}, {}, ...
                mfilename('fullpath'), '"Receiver, Signal or Callback"', 1)
            
            validateattributes(isEnabled, {'numeric', 'logical'}, {'scalar', 'binary'})
            isEnabled = logical(isEnabled);
            
            switch class(receiverOrCallback)
                case 'function_handle'
                    callback = receiverOrCallback;
                    receiver = signals.Receiver(callback, isEnabled);
                    
                case 'signals.Receiver'
                    receiver = receiverOrCallback;
                    
                    if ~isvalid(receiver)
                        error('signals:invalidReceiver', ...
                            'Receiver object is invalid or was deleted.')
                    end
                    
                case 'signals.Signal'
                    % Transfer another signal
                    signal = receiverOrCallback;
                    callback = @(varargin) signal.emit(varargin{:});
                    
                    receiver = signals.Receiver(callback, isEnabled);
            end
            
            if ~self.isReceiverConnected(receiver)
                self.Receivers = vertcat(self.Receivers, receiver);
                
                addlistener(receiver, 'ObjectBeingDestroyed', ...
                    @(src, ed) self.deleteReceiver(src));
            end
            
            if (nargout > 0)
                varargout{1} = receiver;
            end
        end
        
        function disconnect(self, receiver)
            % ����������� ������� �� �������
            %
            % ����� ����������� ������� �� �������� � ������� ��� �� 
            % ������ ���������. ����������� ������� ������������.
            %
            % �������������::
            % @code
            % self.disconnect(receiver)
            % @endcode
            %
            % Parameters:
            % receiver: ������� �������, ������� ��������������� ��� 
            %           ������� ������� @type Receiver
            %
            % @sa connect
            %
            
            narginchk(2, 2)
            
            validateattributes(receiver, {'signals.Receiver'}, {}, ...
                mfilename('fullpath'), 'Receiver', 1)
            
            self.deleteReceiver(receiver);
        end
        
        function clearConnections(self)
            % ������� ��� ���������� ������� � ����������
            %
            % ����� ������� ��� ��������, ������������ � ������� �������.
            %
            % �������������::
            % @code
            % self.clearConnections()
            % @endcode
            %
            % @sa disconnect
            %
            
            self.Receivers = [];
            self.Receivers = signals.Receiver.empty();
        end
        
    end % Public API Methods
    
    
    methods (Access = private)
        
        function emitProxy(self)
            % ��������� ������ ������������ ���������
            
            receivers = self.Receivers;
            data = self.emitData;
            self.emitData = {};
            
            if isempty(data)
                data = {};
            end
            
            try
                if ~isinf(self.argsCount)
                    % ����������� ���������� ���������� � ��������� ������
                    if (numel(data) < self.argsCount)
                        error('signals:emittedArgs', ...
                            'Must be a minimum %d emitted arguments.', self.argsCount);
                    end
                    
                    % ����������� ������ ������������ ���������
                    classes = self.argsClasses;
                    
                    for i = 1:self.argsCount
                        cls = classes{i};
                        
                        if ~isempty(cls)
                            validateattributes(data{i}, cls, {}, ...
                                mfilename('fullpath'), 'emitted argument', i)
                        end
                    end
                end
            catch e
                if self.isAnonymous
                    fprintf(2, 'The error has occurred in the emitted anonymous signal:\n');
                else
                    fprintf(2, 'The error has occurred in the emitted signal "%s" of sender "%s":\n', ...
                        self.Name, class(self.Sender));
                end
                
                fprintf(2, '%s\n', e.message);
                fprintf(2, '\n"%s" signal signature: %s\n', self.Name, self.Arguments);
                return
            end
            
            if isempty(receivers)
                return
            end
            
            % "Sending" a signal to all receivers
            for i = 1:length(receivers)
                r = receivers(i);
                
                try
                    r.receive(self, data{:});
                catch re
                    try
                        self.receiveExceptionHandler(re, r);
                    catch he
                        fprintf(2, 'Error in "ReceiveErrorHandler" in signal:\n');
                        fprintf(2, '%s\n', he.getReport());
                        return
                    end
                end
            end
        end
        
        function deleteReceiver(self, receiver)
            % ������� ������� �� ������ ������������ ���������
            
            i = arrayfun(@(x) receiver==x, self.Receivers);
            self.Receivers(i) = [];
        end
        
        function tf = isReceiverConnected(self, receiver)
            % ���������� true ���� ������� ��� ���������
            
            tf = ismember(receiver, self.Receivers);
        end
        
        function blockSignal(self, flag)
            % ���������/������������ ������
            % Callback ������� ������� �� Sender
            
            self.isBlockSignal = flag;
        end
        
        function receiveExceptionHandler(self, exception, receiver)
            % ��������� ���������� � callback ������� ��������
            
            if self.IsEnabledDisplayReceiveErrors
                self.dispReceiveExceptionInfo(exception)
            end
            
            try
                self.ReceiveErrorHandler.process(exception, self, receiver);
            catch e
                rethrow(e);
            end
        end
        
        function dispReceiveExceptionInfo(self, e)
            % ������� �� ����� ��������� �� ����������
            
            % ������� ������ ����������, ���������� �� �����
            exceptionInfo = regexprep(e.getReport(), ...
                ['\nError in <a href="matlab:helpUtils.', ...
                'errorDocCallback(''signals\.Receiver.*$'], '');
            
            if self.isAnonymous
                fprintf(2, ['The error has occurred in the callback function ', ...
                    'of the receiver connected with the anonymous signal:\n']);
            else
                fprintf(2, ['The error has occurred in the callback function ', ...
                    'of the receiver connected with the signal "%s" of sender "%s":\n'], ...
                    self.Name, class(self.Sender));
            end
            
            fprintf(2, '%s\n\n', exceptionInfo);
        end
        
    end % Private Methods
    
    
    methods (Hidden)
        
        function delete(self)
            
            self.clearConnections()
            self.removeSender()
            
            delete@handle(self)
        end
        
    end % Hidden Methods
    
    
    methods
        % Properties Setters/Getters
        
        function set.Description(self, val)
            if ~isempty(val)
                validateattributes(val, {'char'}, {'row'})
            else
                val = '';
            end
            self.Description = val;
        end
        
        function set.ReceiveErrorHandler(self, val)
            validateattributes(val, {'signals.ErrorHandler'}, {'scalar'})
            self.ReceiveErrorHandler = val;
        end
        
        function set.IsEnabledDisplayReceiveErrors(self, val)
            validateattributes(val, {'numeric', 'logical'}, {'scalar', 'binary'})
            self.IsEnabledDisplayReceiveErrors = logical(val);
        end
        
        function set.IsDirectEmit(self, val)
            validateattributes(val, {'numeric', 'logical'}, {'scalar', 'binary'})
            self.IsDirectEmit = logical(val);
        end
        
        function set.IsEnabled(self, val)
            validateattributes(val, {'numeric', 'logical'}, {'scalar', 'binary'})
            self.proxyListener.Enabled = logical(val);
        end
        
        function val = get.IsEnabled(self)
            val = self.proxyListener.Enabled;
        end
        
        function val = get.Name(self)
            val = '@Anonymous';
            
            if ~self.isAnonymous
                sender = self.Sender;
                props = properties(sender);
                
                for i = 1:length(props)
                    p = props{i};
                    
                    if sender.(p) == self
                        val = p;
                        return
                    end
                end
            end
        end
        
        function val = get.isAnonymous(self)
            val = isempty(self.Sender);
        end
        
    end % Properties Getters/Setters
    
    
    events (Hidden, ListenAccess = private, NotifyAccess = private)
        
        Emit
        
    end
    
end % signals.Signal

