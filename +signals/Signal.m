classdef Signal < handle
    % Класс реализует сигнал
    %
    % Класс реализует функциональность сигнала.
    % Механизм сигналов реализует шаблон проектирования "Observer".
    % Сигналы подобны событиям (events), но более удобны в использовании и 
    % функционально богаче событий. Реализованная парадигма сигналов подобна 
    % парадигме сигналов и слотов в С++ библиотеке Qt.
    %
    % Особенности реализации сигналов::
    % - Сигналы соединяются с приёмниками
    % - Сигналы могут быть соединены с другими сигналами для передачи
    %   по цепочке сигналов
    % - Приёмников сигнала может быть неограниченное количество
    % - Сигналы позволяют пересылать любое количество аргументов
    % - Опционально могут быть заданы обязательные аргументы и типы 
    %   обязательных аргументов.
    % - Сигналы могут иметь или не иметь отправителя.
    % - Если сигнал не имеет отправителя, такой сигнал считается анонимным
    % - Сигнал может быть создан как анонимный, а затем получить отправителя
    % - Отправитель может быть изменён в любой момент
    % - Отправитель сигнала может быть только наследником класса Sender
    % - При получении отправителя, сигнал регистрирует себя у отправителя и 
    %   слушает его события
    % - Сигнал может избавиться от отправителя, после чего удаляет себя у отправителя
    % - Отправитель сам может удалить любой сигнал
    % - При удалении отправителем, объект сигнала уничтожается
    % - Сигнал может быть заблокирован отправителем если имеет его
    %
    % Обработка исключений в приёмниках::
    % Сигналы обрабатывают исключений, которые могут произойти в callback-функциях
    % подключенных приёмников. При возникновении исключения в приёмнике, сигнал
    % по умочланию сообщает об этом сообщением с информацией об ошибке, а
    % так же вызывает функцию-обработчик ошибки, которая может быть задана
    % пользователем. При возникновении исключения в одном из приёмников, сигнал
    % продолжает высылаться для получения другими приёмниками.
    %
    % Использование::
    % @code
    % % Создание анонимного сигнала с любыми высылаемыми аргументами
    % signal = signals.Signal()
    %
    % % Подключение сигнала к приёмнику (создание нового приёмника)
    % receiver = signal.connect(@(x) fprintf('Hello, %s\n', x))
    % signal.emit('World')
    % @endcode
    %
    % @sa
    % Receiver, Sender
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
    
    
    properties (GetAccess = public, SetAccess = private)
        
        % Отправитель данного сигнала
        %
        % Объект, который является отправителем сигнала. Если не указан,
        % сигнал является анонимным.
        %
        % @type Sender @default empty
        Sender
        
    end
    
    properties (Dependent)
        
        % Имя сигнала
        %
        % Имя, c которым сигнал зарегистрирован у отправителя
        % По сути является именем поля, которое хранит объект сигнала в
        % объекте отправителя.
        % Если сигнал анонимный, то Name = "@Anonymous"
        %
        % @type char @default empty
        Name = ''
        
    end
    
    properties (Access = public)
 
        % Описание сигнала
        %
        % Строка описания сигнала. 
        % Описание может быть задано пользователем.
        %
        % @type char @default empty
        Description = ''
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        % Аргументы сигнала (строка)
        %
        % Строка с описанием обязательных аргументов сигнала и их типов
        %
        % @type char
        Arguments
        
        % Приёмники, соединённые с данным сигналом
        %
        % Массив приёмников, которые подключены к данному сигналу
        %
        % @type Receiver
        Receivers
        
    end
    
    properties (Access = public)
        
        % Обработчик ошибки при возникновении исключения в приёмниках
        %
        % Хранит ссылку на экземпляр класса, наследуемого от ErrorHandler. 
        % Когда в любом приёмнике, подключенном к данному сигналу, произойдёт 
        % исключение, будет вызван метод process этого класса.
        %
        % Сигнатура функции process:
        %   process(exception, signal, receiver)
        %
        % Входные аргументы:
        %   exception -- Объект MExceptions с информацией об исключении
        %   signal    -- Объект сигнала
        %   receiver  -- Объект приёмника, в котором произошло исключение
        %
        % @note
        %   Если в ReceiveErrorHandler происходит исключение, то дальнейшая
        %   рассылка сигнала завершается с исключительной ситуацией.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % Флаг указывает, будут ли отображаться сообщения об ошибках в приёмниках
        %
        % Если данный флаг установлен в true, то все ошибки, возникающие в
        % приёмниках будут отображаться в командном окне.
        %
        % @note
        %   Флаг никак не влияет на обработчик ReceiveErrorHandler, который
        %   всегда вызывается при ошибках в приёмника.
        %
        % @type logical @default true
        IsEnabledDisplayReceiveErrors = true
        
        % Флаг определяет, будет ли сигнал высылаться напрямую без
        % использования системы событий (Events)
        %
        % Если данный флаг установлен в true, то сигнал будет высылаться
        % прямым вызовом функции высылки сигнала, а не через генерацию
        % события Emit.
        %
        % @type logical @default false
        IsDirectEmit = false
        
    end
    
    properties (Dependent)
        
        % Флаг определят состояние сигнала вкл/выкл
        %
        % Если значение флага true, то включенные приёмники будут его принимать,
        % если значение флага false, то включенные приёмники не будут его принимать.
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
            % Конструктор
            %
            % Создаёт экземпляр сигнала.
            %
            % Использование::
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
            %   sender: Объект отправителя @type Sender
            %   name: Имя сигнала, которое будет определно как property в sender @type char
            %   argTypes: Типы обязательных аргументов сигнала @type cell
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
            % Устанавливает для сигнала отправителя
            %
            % Метод задаёт сигналу отправителя. Если сигнал уже имеет 
            % отправителя, он будет сменён на задаваемого, т.к. сигнал не
            % может иметь нескольких отправителей.
            % Если вторым аргументом задаётся имя, сигнал будет добавлен
            % в объект отправителя как динамическое поле с именем name.
            %
            % Использование::
            % @code
            % obj.setSender(sender, name)
            % obj.setSender(sender)
            % @endcode
            %
            % Parameters:
            %   sender: Объект отправителя. Должен наследоваться от Sender
            %   name: Имя поля в объекте отправителя, в которое будет добавлен сигнал
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
                % Если указано имя сигнала, то регистрируем сигнал у отправителя
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
            % Удаляет сигнал у отправителя
            %
            % Метод удаляет ссылку на сигнал у текущего отправителя.
            % Это действие делает сигнал анонимным.
            %
            % Использование::
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
            % Устанавливает количество и типы обязательных аргументов сигнала
            %
            % Метод устанавливает количество и тип обязательных аргументов,
            % которые будут переданы при испускании сигнала.
            %
            % Использование::
            % @code
            %   % сигнал может испускаться с любым количеством аргументов любого типа
            %   self.setRequiredArgs()
            %
            %   % сигнал может испускаться с заданным количеством аргументов заданного типа
            %   self.setRequiredArgs(typeArg1, typeArg2, ..., typeArgN)
            %
            %   % сигнал может испускаться с заданным количеством аргументов любого из перечисленных типов
            %   self.setRequiredArgs({type1Arg1, type2Arg1, ..., typeNArg1}, ...)
            %
            %   % сигнал может испускаться с заданным количеством аргументов любого типа
            %   self.setRequiredArgs({}, {}, ..., {})
            %
            %   % сигнал может испускаться с любым количеством аргументов любого типа, следующих после обязательных
            %   self.setRequiredArgs(..., varargin)
            % @endcode
            %
            % Примеры::
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
            % Испускает сигнал
            %
            % Метод испускает сигнал с заданными аргументами.
            % Количество и тип аргументов зависят от сигнатуры сигнала.
            % @n
            % Все приёмники сигнала, которые включены, (callback-функции) 
            % будут вызваны.
            % 
            % Использование::
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
            % Подключает приёмник к сигналу
            %
            % Метод подключает приёмник к данному сигналу.
            % Если в качестве входного аргумента задана callback-функция или
            % сигнал, то метод создаёт новый приёмник, если задан объект приёмника,
            % метод добавляет его в список подключенных приёмников если его
            % там ещё нет.
            %
            % @warning
            % Если сигнал соединяется с другим сигналом, оба сигнала должны
            % быть согласованы по своим аргументам, т.е. у них должна быть
            % одинаковая сигнатура, иначе испускание подключенного сигнала 
            % завершится с ошибкой.
            %
            % Использование::
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
            % receiver:  Объект уже созданного приёмника. @type Receiver
            % callback:  указатель на функцию, которая будет 
            %            вызываться при испускании сигнала @type function_handle
            % signal:    Объект другого сигнала, который будет пересылать
            %            сигнал, испущенный этим сигналом.
            % isEnabled: Флаг указывает, будет ли включен приемник при подключении.
            %            Имеет силу толкьо если в качестве первого аргумента передаётся
            %            callback-функция. @type logical @default true
            %
            % Return values:
            % receiver: Ссылка на объект созданного приёмника @type Receiver
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
            % Отсоединяет приёмник от сигнала
            %
            % Метод отсоединяет приёмник от сигналов и удаляет его из 
            % списка приёмников. Отключенный приёмник уничтожается.
            %
            % Использование::
            % @code
            % self.disconnect(receiver)
            % @endcode
            %
            % Parameters:
            % receiver: Приёмник сигнала, который зарегистрирован для 
            %           данного сигнала @type Receiver
            %
            % @sa connect
            %
            
            narginchk(2, 2)
            
            validateattributes(receiver, {'signals.Receiver'}, {}, ...
                mfilename('fullpath'), 'Receiver', 1)
            
            self.deleteReceiver(receiver);
        end
        
        function clearConnections(self)
            % Очищает все соединения сигнала с приёмниками
            %
            % Метод удаляет все приёмники, подключенные к данному сигналу.
            %
            % Использование::
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
            % Рассылает сигнал подключенным приёмникам
            
            receivers = self.Receivers;
            data = self.emitData;
            self.emitData = {};
            
            if isempty(data)
                data = {};
            end
            
            try
                if ~isinf(self.argsCount)
                    % Определённое количество аргументов с заданными типами
                    if (numel(data) < self.argsCount)
                        error('signals:emittedArgs', ...
                            'Must be a minimum %d emitted arguments.', self.argsCount);
                    end
                    
                    % Проверяются только обязательыне аргументы
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
            % Удаляет приёмник из списка подключенных приёмников
            
            i = arrayfun(@(x) receiver==x, self.Receivers);
            self.Receivers(i) = [];
        end
        
        function tf = isReceiverConnected(self, receiver)
            % Возвращает true если приёмник уже подключен
            
            tf = ismember(receiver, self.Receivers);
        end
        
        function blockSignal(self, flag)
            % Блокирует/разблокирует сигнал
            % Callback слушает события из Sender
            
            self.isBlockSignal = flag;
        end
        
        function receiveExceptionHandler(self, exception, receiver)
            % Обработка исключения в callback функции приёмника
            
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
            % Выводит на экран сообщение об исключении
            
            % Убираем лишнюю информацию, полученную из стека
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

