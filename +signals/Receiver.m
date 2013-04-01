classdef Receiver < handle
    % Класс реализует приёмник сигналов
    %
    % Класс реализует функциональность приёмника сигналов.
    % Этот класс используется совместно с классом Signal.
    %
    % Особенности реализации приёмника::
    % - Приёмник может быть подключен к нескольким сигналам одновременно.
    % - Приёмник может быть включен и отключен для приёма сигналов
	% - Исключение в callback-функции приёмника не останавливает рассылку 
    %   сигнала другим приёмникам (поведение может зависеть от параметров сигнала)
    % - В приёмнике может быть определен функция-handler для обработки исключений
    %
    % Использование::
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
    %   Проект    : M-Signals
    %   Версия    : 1.0
    %   Автор     : Евгений Прилепин
    %   Создано   : 27.12.11
    %   Обновлено : 23.01.13
    %
    %   Copyright : (C) 2011-2013 Евгений Прилепин
    % ---------------------------------------------------------------------
    
    properties (Access = public)
        
        % Указатель на callback-функцию
        %
        % Указатель на функцию или метод класса, который будет выполнен при
        % испускании сигнала, который принимает приёмник.
        %
        % @type function_handle
        Callback
        
        % Callback-функция, вызываемая при возникновении исключения в данном приёмнике
        %
        % Хранит ссылку на экземпляр класса, наследуемого от ErrorHandler. 
        % Когда в приёмнике, подключенном к некоторому сигналу, произойдёт 
        % исключение при генерации сигнала, будет вызван метод process этого класса.
        %
        % Сигнатура функции process:
        %   process(exception, signal, receiver)
        %
        % Входные аргументы:
        %   exception -- Объект MExceptions с информацией об исключении
        %   signal    -- Объект сигнала, который принимался в момент возникновения исключения
        %   receiver  -- Объект приёмника, в котором произошло исключение
        %
        % @note
        %   Если в ReceiveErrorHandler происходит исключение, то информация о
        %   нем выводится в командное окно, но оно не перехватывается на уровне сигнала.
        %
        % @type ErrorHandler
        ReceiveErrorHandler
        
        % Флаг определяет, включен ли данный приёмник на получение сигнала
        %
        % @type logical @default true
        IsEnabled
        
    end
    
    
    methods
        % Public API methods
        
        function self = Receiver(callback, isEnabled)
            % Конструктор
            %
            % Создаёт экземпляр класса Receiver.
            %
            % Использование::
            %   self = Receiver(callback)
            %   self = Receiver(callback, isEnabled)
            %
            % Parameters:
            %   callback: Указатель на функцию, которая будет выполнена 
            %             при испускании сигнала @type function_handle
            %   isEnabled: Флаг определяет, включен ли приёмник. @type logical @default true
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
            % Принимает испущенный сигнал
            %
            % Метод принимает сигнал и выполняет функцию, заданную в 
            % Callback если IsEnabled = true.
            %
            % Использование::
            %   self.receive(signal, varargin)
            %
            % Parameters:
            %   signal -- объект принимаемого сигнала
            %   varargin -- аргументы принимаемого сигнала
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
                    % Убираем по одному аргументу с конца, чтобы в итоге
                    % вызвать функцию с требуемым количеством аргументов.
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
            % Определяет аргументы сигнала, которые могут быть переданы в Callback
            
            args = varargin;
            
            try
                % Error using nargin
                % Unable to ensure a valid workspace for the function ...
                argsMax = nargin(self.Callback);
            catch e %#ok<NASGU>
                argsMax = -1;
            end
            
            if (argsMax == 0)
                % Callback не принимает аргументов
                args = {};
                
            elseif (argsMax < 0)
                % Callback принимает varargin
                return
                
            elseif (argsMax > 0)
                % Callback принимает определённое кол. аргументов
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

