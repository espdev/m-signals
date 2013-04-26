classdef Signal < handle
    % Class implements signal 
    %
    % Class implements signal functionality. 
    % Signal mechanism implements "Observer" design pattern. 
    % Signals are similar to the events. However, it is more convenient to
    % use signals than the events signals. Signals are functionally richer
    % than the events. Implemented signal paradigm is
    % similar to signals and slots paradigm in C++ Qt.
    %
    % Signals implementation features::
    % - Signals can be connected to the receivers.
    % - Signals can be connected to other signals for their 
    %   transmission through a signal chain
    % - The number of receivers can be unlimited.
    % - Signals allow resending any number of arguments.
    % - Optionally, mandatory arguments as well as their types can be assigned.
    % - Signals can have or cannot have a sender.
    % - If a signal does not have a sender, the signal is considered to be
    %   an anonymous signal.
    % - Signal can be created as an anonymous signal and then a sender can
    %   be assigned to a signal.
    % - Sender can be changed at any time.
    % - Signal sender can be only the entity inherited from Sender class
    % - When a signal is assigned to a sender, the signal registers itself
    % with the sender and listens to its events.
    % - Having removed a sender, the signal deletes itself from a sender. 
    % - Sender can delete signals.
    % - When a sender deletes a signal, the signal instance will be deleted.
    % - A signal can be blocked by a sender, in case if a signal has a senders.
    %
    % Exception handling in the receivers::
    % Signals handle exceptions that can occur in the callback functions
    % of the enabled receivers. The exception appeared in one of the
    % receivers, a signal, by default, informs about an error message and
    % calls an error handler that can be specified by the user ErrorHandler
    % class.
    % The exception appeared in one of the receivers, the signal 
    % continues being sent to other receivers to be obtained.
    %
    % Usage::
    % @code
    % % Creation of the anonymous signal with any passing arguments 
    % signal = signals.Signal()
    %
    % % Creating signal receiver connection(the creation of a new receiver)
    % receiver = signal.connect(@(x) fprintf('Hello, %s\n', x))
    % signal.emit('World')
    % @endcode
    %
    % @sa
    % Receiver, Sender
    %
    
    % ---------------------------------------------------------------------
    % Project   : M-Signals
    % Version   : 1.0
    % Author    : Evgeny Prilepin 
    % Created   : 27.12.11
    % Updated   : 31.03.13
    %
    % Copyright : (C) 2011-2013 Evgeny Prilepin
    % ---------------------------------------------------------------------
    
    
    properties (GetAccess = public, SetAccess = private)
        
        % Signal sender
        %
        % Instance is a signal sender. If the instance is not specified 
        % the signal is regarded to be an anonymous one. 
        %
        % @type Sender @default empty
        Sender
        
    end
    
    properties (Dependent)
        
        % Signal name
        %
        % Name under which the signal has been registered in a sender. 
        % In essence, signal name is a name of a field, containing signal 
        % instance in the instance of a sender.
        % If signal is anonymous then its Name = "@Anonymous"
        %
        % @type char @default empty
        Name = ''
        
    end
    
    properties (Access = public)
 
        % Signal description
        %
        % Signal description string.
        % Description can be assigned by a user. 
        %
        % @type char @default empty
        Description = ''
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        % Signal arguments string
        %
        % String containing the description of signal mandatory arguments 
        % and their types        
        % @type char
        Arguments
        
        % Receivers connected to this signal 
        %
        % Receivers array connected to this signal 
        %
        % @type Receiver
        Receivers
        
    end
    
    properties (Access = public)
        
        % The exception occurred in the receivers, the error handler 
        %
        % saves the reference to the instance class inherited from
        % ErrorHandler.
        % The exception occurred in the receiver connected to this signal,
        % method "process" of this class is called.
        % signal, method "process" of this class is called.
        %
        % "process" function signature:
        %   process (exception, signal, receiver)
        %
        % Input arguments:
        %   exception -- Object MExceptions containing the information
        %                about the exception
        %   signal    -- signal object
        %   receiver  -- Receiver object in which the exception occurred 
        %
        % @note
        %   Should the exception occur in ReceiveErrorHandler, the 
        %   further signal emission stops.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % Flag indicates the display of error messages in the receivers        
        %
        % If the flag has value "True", all errors, occurring in the  
        % receivers, will be displayed in the command window.
        %
        % @note
        %   Flag does not influence ReceiveErrorHandler, error handler, 
        %   always called with errors in the receiver.
        %
        % @type logical @default true
        IsEnabledDisplayReceiveErrors = true
        
        % Flag indicates whether a signal has been emitted directly
        % without the event-driven system. (Events)
        %
        % If the flag has value "True", then the signal will be called 
        % directly by signal emission function, but not through the 
        % generation of the event Emit.
        %
        % @type logical @default false
        IsDirectEmit = false
        
    end
    
    properties (Dependent)
        
        % Flag indicates whether the signal is enabled or disabled 
        %
        % If the flag value is "True", then enabled receivers will receive
        % the signal.
        % if the flag value is "False", then the enabled receivers will not
        % receive the signal.
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
            % Constructor
            %
            % creates signal instance
            %
            % Usage::
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
            %   sender: Sender's object @type Sender
            %   name: Signal name that will be defined as "property" in
            %         sender @type char
            %   argTypes: Types of signal mandatory arguments @type cell
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
            % Sets up a sender
            %
            % The method sets up a sender. If a signal has a sender, 
            %, the sender will be replaced by a newly defined one, 
            % as a signal cannot have several senders.            

            % If the second argument sets up a signal name, the signal will
            % be added to the sender's instance as a dynamic field under
            % the name "name".
            %
            % Usage::
            % @code
            % obj.setSender(sender, name)
            % obj.setSender(sender)
            % @endcode
            %
            % Parameters:
            %   sender: Sender's object shall be inherited from Sender 
            %   name: Field name in the sender's instance, signal shall be added to this field
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
                % If signal name is specified, signal is registered with
                % the sender
                prop = sender.findprop(name);
                
                if isempty(prop)
                    % Если поля нет, добавляем и устанавливаем в его 
                    % значение сигнал.
                    self.senderProp = sender.addprop(name);
                    sender.(name) = self;
                else
                    % Если поле уже есть, то генерируем исключение если это
                    % поле не является нашим сигналом. Нельзя создавать
                    % сигналы с именами уже существующих полей в сендере.
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
            % Deletes signal from sender 
            %
            % The method deletes the reference to a single from the current
            % sender.
            % This action makes signal anonymous.
            %
            % Usage::
            % @code
            % obj.removeSender()
            % @endcode
            %
            % @sa setSender
            %
            
            if self.isAnonymous
                return
            end
            
            delete(self.senderProp)
            delete(self.signalBlockedListener)
            delete(self.signalUnblockedListener)
            
            self.Sender = [];
        end
        
        function setRequiredArgs(self, varargin)
            % Sets up the number and type of signal mandatory arguments 
            %
            % The method sets up the number and type of signal mandatory
            % arguments that will be transmitted with the signal emission. 
            %
            % Usage::
            % @code
            %   % Signal can be emitted with any number of arguments of any type.
            %   self.setRequiredArgs()
            %
            %   % Signal can be emitted with a specified number of arguments of a specified type. 
            %   self.setRequiredArgs(typeArg1, typeArg2, ..., typeArgN)
            %
            %   % Signal can be emitted with a specified number of arguments of the following type 
            %   self.setRequiredArgs({type1Arg1, type2Arg1, ..., typeNArg1}, ...)
            %
            %   % Signal can be emitted with a specified number of arguments of any type 
            %   self.setRequiredArgs({}, {}, ..., {})
            %
            %   % Signal can be emitted with any number of arguments of any type, following the mandatory arguments 
            %   self.setRequiredArgs(..., varargin)
            % @endcode
            %
            % Examples::
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
            % Emits signal
            %
            % The method emits signal with specified arguments
            % The number and type of arguments depend on the signal
            % signature.
            % @n
            % All enabled signal receivers (callback function) 
            % will be called.
            % 
            % Usage::
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
            % Connects the receiver to the signal
            %
            % The method connects the receiver to the signal.
            % If the input argument is defined as a callback-function or 
            % a signal, method creates a new receiver; if the input
            % argument is, specified as the instance of a receiver, method
            % adds it to its list of connected receivers if this argument
            % has not been added earlier.
            %
            % @warning
            % If a signal connects to the other signal, both signals
            % shall be conformed to arguments, i.e. they must have the 
            % same signature, otherwise, 
            % the signal emission will fail.
            %
            % Usage::
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
            % receiver:  The object of the created receiver. @type Receiver
            % callback:  function handle is called with the signal emission 
            %            @type function_handle
            % signal:    The object of the other signal is to transmit 
            %            signal emitted by this signal  
            % isEnabled: Flag indicates whether the receiver is enabled or
            %            disabled.
            %            Flag value is ignored if first argument is not the
            %            callback function. @type logical @default true
            %
            % Return values:
            % receiver: the reference to the object of the created receiver
            %           @type Receiver
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
            % Disconnects receiver from a signal
            %
            % The method disconnects the receiver from signals and 
            % deletes it from the list of receivers.
            %
            % Usage::
            % @code
            % self.disconnect(receiver)
            % @endcode
            %
            % Parameters:
            % receiver: Signal receiver registered for 
            %           this signal @type Receiver
            %
            % @sa connect
            %
            
            narginchk(2, 2)
            
            validateattributes(receiver, {'signals.Receiver'}, {}, ...
                mfilename('fullpath'), 'Receiver', 1)
            
            self.deleteReceiver(receiver);
        end
        
        function clearConnections(self)
            % Clears all signal-receiver connections 
            %
            % The method deletes all receivers connected to the signal.
            %
            % Usage::
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
            % Sells signal to enabled receivers
            
            receivers = self.Receivers;
            data = self.emitData;
            self.emitData = {};
            
            if isempty(data)
                data = {};
            end
            
            try
                if ~isinf(self.argsCount)
                    % Definite number of arguments of a specified type
                    if (numel(data) < self.argsCount)
                        error('signals:emittedArgs', ...
                            'Must be a minimum %d emitted arguments.', self.argsCount);
                    end
                    
                    % Only mandatory arguments are to be checked
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
            % Deletes the receiver from the list of connected receivers
            
            if ~isvalid(self)
                return
            end
            
            i = arrayfun(@(x) receiver==x, self.Receivers);
            self.Receivers(i) = [];
        end
        
        function tf = isReceiverConnected(self, receiver)
            % Returns "True" if the receiver has been already connected
            
            tf = ismember(receiver, self.Receivers);
        end
        
        function blockSignal(self, flag)
            % Blocks/unblocks signal
            % Callback listens to the events from Sender
            
            self.isBlockSignal = flag;
        end
        
        function receiveExceptionHandler(self, exception, receiver)
            % Exception handling in the receiver's callback function
            
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
            % Displays error message
            
            % Remove odd information from the stack
            exceptionInfo = regexprep(e.getReport(), ...
                ['\nError in <a href="matlab:helpUtils.', ...
                'errorDocCallback(''signals\.Receiver.*$'], '');
            
            if self.isAnonymous
                fprintf(2, ['The error has occurred in the callback function ', ...
                    'of the receiver connected to the anonymous signal:\n']);
            else
                fprintf(2, ['The error has occurred in the callback function ', ...
                    'of the receiver connected to the signal "%s" of sender "%s":\n'], ...
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
