classdef Sender < dynamicprops
    % Класс реализует функциональность отправителя сигналов
    %
    % Класс реализует функциональность отправителя сигналов.
    % @n
    % Если в классе-наследнике данного класса есть поля, которые содержат 
    % ссылки на сигналы, они будут считаться сигналами отправителя, и с ними
    % можно будет производить какие-либо действия, например, 
    % блокировать/разблокировать сигналы централизованно, назначать единого
    % обработчика исключений и т.д.
    % В объекте класса наследника Sender можно динамически создавать и удалять
    % сигналы.
    %
    % Использование::
    % @code
    % % Определение класса, наследующегося от handle с примесью Sender
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
    % % Использование сигналов
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
    %   Проект    : M-Signals
    %   Версия    : 1.0
    %   Автор     : Евгений Прилепин
    %   Создано   : 27.12.11
    %   Обновлено : 31.03.13
    %
    %   Copyright : (C) 2011-2013 Евгений Прилепин
    % ---------------------------------------------------------------------
    
    properties (Access = public)
        
        % Флаг определяет, будут ли блокироваться сигналы отправителя
        %
        % Если это свойство true, все сигналы отправителя будут блокироваться.
        %
        % @note Анонимные сигналы (не имеющие отправителя) не блокируются.
        %
        % @type logical @default false
        IsBlockSignals = false;
        
    end
    
    
    methods
        % Public API Methods

        function varargout = signals(self)
            % Возвращает или выводит в командное окно список сигналов объекта
            %
            % Метод возвращает список или выводит на экран список сигналов
            % объекта.
            %
            % Использование::
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
            % Создаёт новый сигнал в динамическом поле объекта отправителя
            %
            % Метод создаёт сигнал и добавляет его в динамическое поле 
            % объекта отправителя.
            %
            % Использование::
            % @code
            % self.createSignal(signalName)
            % self.createSignal(signalName, argTypess1, argTypess2, ...)
            % signal = self.createSignal(...)
            % @endcode
            %
            % Parameters:
            % signalName: Имя сигнала и динамического поля, в котором будет создан сигнал. @type char
            % argTypes: Типы обязательных аргументов сигнала. @type cell
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
                % Если такое поле уже существует и является сигналом, то
                % не создаём новый сигнал
                s = self.(signalName);
            else
                s = signals.Signal(self, signalName, varargin{:});
            end
            
            if (nargout == 1)
                varargout{1} = s;
            end
        end
        
        function deleteSignal(self, signalOrName)
            % Удаляет сигнал, созданный динамически в объекте отправителе
            %
            % Метод удаляет существующий сигнал, который был создан динамически
            % и удаляет его поле из объекта. После удаления объект сигнала 
            % будет разрушен.
            %
            % Использование::
            % @code
            % self.deleteSignal(signal)
            % self.deleteSignal(signalName)
            % @endcode
            %
            % Parameters:
            % signal: Объект сигнала. @type Signal
            % signalName: Имя сигнала. @type char
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
                % Может быть удалён сигнал, который был создан как динамическое свойство
                return
            end
            
            delete(signal)
        end
        
        function createSignalsFromEvents(self)
            % Создаёт сигналы в объекте отправителя с именами событий
            %
            % Метод создаёт динамические сигналы в объекте отправителя с 
            % именами событий, существующих в этом объекте.
            %
            % @note
            % Имена сигналов (и полей объекта) будут совпадать с именами событий.
            %
            % Использование::
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
