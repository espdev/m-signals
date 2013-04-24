classdef Sender < dynamicprops
    % Class implements signal sender functionality.
    %
    % Class implements signal sender functionality.
    % @n
    % If in the subclass there are any signals, 
    % these signals will be regarded as 
    % sender signals on which it is possible to perform actions like 
    % blocking/unblocking signals centrally, 
    % assigning unified exception handler, and etc.  
    % In the Sender class instance it is possible to create or delete 
    % signals dynamically. 
    %
    % Usage::
    % @code
    % % Defining class inherited from "handle" with Sender mixin
    % classdef TestSignals < handle & signals.Sender
    %     
    %     properties (GetAccess = public, SetAccess = private)
    %         Created
    %     end
    %
    %     events
    %         FooBar
    %     end
    %
    %     methods
    %         function self = TestSignals()
    %             self.Created = signals.Signal(self)
    %
    %             self.createSignal('Changed')
    %             self.createSignal('Updated', {'numeric})
    %
    %             self.createSignalsFromEvents()
    %         end
    %     end
    % end
    %
    % % Signal usage
    % test = TestSignals()
    %
    % signals(test)
    %
    % test.Changed.connect(@(x) fprintf('hello, %s\n', x))
    % test.Changed.emit('Matlab')
    % @endcode
    %
    % @sa 
    % Signal, Receiver
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
    
    properties (Access = public)
        
        % Flag defines whether the sender signals are blocked or unblocked.        
        %
        % If the flag value is "True", all sender signals will be blocked.
        %
        % @note Anonymous signals (signals that do not have a sender) will
        % not be blocked.
        %
        % @type logical @default false
        IsBlockSignals = false;
        
    end
    
    
    methods
        % Public API Methods

        function varargout = signals(self)
            % Returns a list of object signals or displays it in the command prompt window 
            %
            % Method returns a list of object signals or displays it in 
            % the command prompt window.
            %
            % Usage::
            % @code
            %   self.signals()
            %   s = self.signals()
            % @endcode
            %
            
            nargoutchk(0, 1)
            
            props = properties(self);
            isSignals = cellfun(@(x) isa(self.(x), 'signals.Signal'), props);
            signalProps = props(isSignals);
            
            if (nargout == 1)
                varargout{1} = signalProps(:);
                return
            end
            
            meta = metaclass(self);
            
            fprintf('Signals for class %s:\n', meta.Name);
            
            for i = 1:length(signalProps)
                fprintf('    %s\n', signalProps{i});
            end
        end
        
        function varargout = createSignal(self, signalName, varargin)
            % Creates a new signal in the dynamic property of the object sender 
            %
            % Method creates a signal and adds it to the dynamic property  
            % of the object sender.
            %
            % Usage::
            % @code
            % self.createSignal(signalName)
            % self.createSignal(signalName, argTypess1, argTypess2, ...)
            % signal = self.createSignal(...)
            % @endcode
            %
            % Parameters:
            % signalName: Signal name and the name of the dynamic property
            %             in which a signal will be created. @type char
            % argTypes: Types of mandatory signal arguments. @type cell
            %
            % @sa
            % deleteSignal
            %
            
            narginchk(2, Inf)
            nargoutchk(0, 1)
            
            validateattributes(signalName, {'char'}, {'row'})
            
            props = properties(self);
            
            if (ismember(signalName, props) && ...
                isa(self.(signalName), 'signals.Signal'))
                % If there is a property and this property is a signal,
                % then a new signal is not created
                s = self.(signalName);
            else
                s = signals.Signal(self, signalName, varargin{:});
            end
            
            if (nargout == 1)
                varargout{1} = s;
            end
        end
        
        function deleteSignal(self, signalOrName)
            % Deletes dynamically created signal in the sender object 
            %
            % Method deletes the dynamically created signal and then 
            % deletes its property from the object.  When the signal and
            % the property are deleted, signal object shall be destroyed.
            %
            % Usage::
            % @code
            % self.deleteSignal(signal)
            % self.deleteSignal(signalName)
            % @endcode
            %
            % Parameters:
            % signal: Signal object. @type Signal
            % signalName: Signal name. @type char
            %
            % @sa
            %   createSignal
            %
                        
            narginchk(2, 2)
            
            validateattributes(signalOrName, {'signals.Signal', 'char'}, {})
            
            if isa(signalOrName, 'char')
                signalProp = findprop(self, signalOrName);
                
                if ~isempty(signalProp)
                    signal = self.(signalOrName);
                end
            else
                signal = signalOrName;
                signalProp = findprop(self, signal.Name);
            end
            
            if (isempty(signalProp) || ~isa(signalProp, 'meta.DynamicProperty'))
                % The signal created as a dynamic property can be deleted
                return
            end
            
            delete(signal)
        end
        
        function createSignalsFromEvents(self)
            % Creates signals in the sender object with the event names 
            %
            % Method creates dynamic signals in the sender object with
            % the names of the events, existing in this object.
            %
            % @note
            % Signal names (and property names) will correspond to event
            % names.
            %
            % Usage::
            % @code
            % self.createSignalsFromEvents()
            % @endcode
            %
            % @sa createSignal, deleteSignal
            %
            
            meta = metaclass(self);
            eventsList = meta.EventList;
            
            for i = 1:length(eventsList)
                event = eventsList(i);
                name = event.Name;
                
                if (strcmpi(event.NotifyAccess, 'public') && ...
                    strcmpi(event.ListenAccess, 'public'))
                    
                    self.createSignal(name);
                end
            end
        end
        
    end % Public API Methods
    
    
    methods
        
        function set.IsBlockSignals(self, val)
            validateattributes(val, {'numeric', 'logical'}, {'scalar'})
            self.IsBlockSignals = logical(val);
            
            if val
                notify(self, 'SignalsBlocked')
            else
                notify(self, 'SignalsUnblocked')
            end
        end
        
    end
    
    
    events (Hidden, NotifyAccess = private, ListenAccess = ?signals.Signal)
        
        SignalsBlocked
        SignalsUnblocked
        
    end
    
end % Sender
