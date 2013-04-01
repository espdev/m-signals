classdef Sender < dynamicprops
    % ����� ��������� ���������������� ����������� ��������
    %
    % ����� ��������� ���������������� ����������� ��������.
    % @n
    % ���� � ������-���������� ������� ������ ���� ����, ������� �������� 
    % ������ �� �������, ��� ����� ��������� ��������� �����������, � � ����
    % ����� ����� ����������� �����-���� ��������, ��������, 
    % �����������/�������������� ������� ���������������, ��������� �������
    % ����������� ���������� � �.�.
    % � ������� ������ ���������� Sender ����� ����������� ��������� � �������
    % �������.
    %
    % �������������::
    % @code
    % % ����������� ������, �������������� �� handle � �������� Sender
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
    % % ������������� ��������
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
    %   ������    : M-Signals
    %   ������    : 1.0
    %   �����     : ������� ��������
    %   �������   : 27.12.11
    %   ��������� : 31.03.13
    %
    %   Copyright : (C) 2011-2013 ������� ��������
    % ---------------------------------------------------------------------
    
    properties (Access = public)
        
        % ���� ����������, ����� �� ������������� ������� �����������
        %
        % ���� ��� �������� true, ��� ������� ����������� ����� �������������.
        %
        % @note ��������� ������� (�� ������� �����������) �� �����������.
        %
        % @type logical @default false
        IsBlockSignals = false;
        
    end
    
    
    methods
        % Public API Methods

        function varargout = signals(self)
            % ���������� ��� ������� � ��������� ���� ������ �������� �������
            %
            % ����� ���������� ������ ��� ������� �� ����� ������ ��������
            % �������.
            %
            % �������������::
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
            % ������ ����� ������ � ������������ ���� ������� �����������
            %
            % ����� ������ ������ � ��������� ��� � ������������ ���� 
            % ������� �����������.
            %
            % �������������::
            % @code
            % self.createSignal(signalName)
            % self.createSignal(signalName, argTypess1, argTypess2, ...)
            % signal = self.createSignal(...)
            % @endcode
            %
            % Parameters:
            % signalName: ��� ������� � ������������� ����, � ������� ����� ������ ������. @type char
            % argTypes: ���� ������������ ���������� �������. @type cell
            %
            % @sa
            %   deleteSignal
            %
            
            narginchk(2, Inf)
            nargoutchk(0, 1)
            
            validateattributes(signalName, {'char'}, {'row'})
            
            props = properties(self);
            
            if (ismember(signalName, props) && ...
                isa(self.(signalName), 'signals.Signal'))
                % ���� ����� ���� ��� ���������� � �������� ��������, ��
                % �� ������ ����� ������
                s = self.(signalName);
            else
                s = signals.Signal(self, signalName, varargin{:});
            end
            
            if (nargout == 1)
                varargout{1} = s;
            end
        end
        
        function deleteSignal(self, signalOrName)
            % ������� ������, ��������� ����������� � ������� �����������
            %
            % ����� ������� ������������ ������, ������� ��� ������ �����������
            % � ������� ��� ���� �� �������. ����� �������� ������ ������� 
            % ����� ��������.
            %
            % �������������::
            % @code
            % self.deleteSignal(signal)
            % self.deleteSignal(signalName)
            % @endcode
            %
            % Parameters:
            % signal: ������ �������. @type Signal
            % signalName: ��� �������. @type char
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
                % ����� ���� ����� ������, ������� ��� ������ ��� ������������ ��������
                return
            end
            
            delete(signal)
        end
        
        function createSignalsFromEvents(self)
            % ������ ������� � ������� ����������� � ������� �������
            %
            % ����� ������ ������������ ������� � ������� ����������� � 
            % ������� �������, ������������ � ���� �������.
            %
            % @note
            % ����� �������� (� ����� �������) ����� ��������� � ������� �������.
            %
            % �������������::
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
