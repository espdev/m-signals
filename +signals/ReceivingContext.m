classdef (Sealed) ReceivingContext < handle
    % Предоставляет возможность получения данных в контексте приёма сигналов
    %
    % Description:
    %   Класс обеспечивает доступ к данным контекста приёма сигнала в
    %   callback-функции приёмника, если в этом есть серьёзная
    %   неоходимость.
    %
    %   Позволяет получить следующие данные:
    %   - Информацию об объекте отправителе, если сигнал не был анонимным
    %     (ссылку на экземпляр отправителя, либо [] для анонимного сигнала)
    %   - Информацию об объекте сигнала (ссылку на экземпляр сигнала)
    %   - Информацию об объекте приёмника (ссылку на экземпляр приёмника)
    %
    % @note
    % Не рекомендуется использовать данный класс без острой необходимости,
    % т.к. его использование увеличивает связанность модулей, нарушает
    % инкапсуляцию данных и общую парадигму использования "Сигналов и слотов".
    %
    % @warning
    % Данный класс является Singleton-классом, т.е. глобальным. При каждом
    % новом получении сигнала приёмником, информация в полях класса будет
    % перезаписана новыми данными.
    %
    % @warning
    % Текущие данные контекста существуют только во время выполнения
    % callback-функции приёмника. Данные контекста будут очищены сразу
    % после завершения выполнения callback-функции.
    %
    % Usage:
    % Предполагается, что контекст будет использоваться в callback-функции
    % приёмника.
    % Пример использования:
    %
    % @code
    % function someCallback()
    %     % Callback-функция приёмника, которая выполняется при приёме сигнала
    %
    %     % Получаем текущие данные контекста приёма сигнала
    %     context = signals.ReceivingContext.getContext()
    %
    %     % Информация об отправителе
    %     sender = context.Sender
    %     
    %     % Информация о сигнале
    %     signal = context.Signal
    %
    %     % Какие-то действия...
    %
    % end
    % @endcode
    %
    %
    % See also: signals.Receiver
    %
    
    % ---------------------------------------------------------------------
    % Project    : M-Signals
    % Version    : 1.0
    % Author     : Evgeny Prilepin 
    % Created    : 31.03.11
    % Updated    : 28.04.13
    %
    % Copyright : (C) 2011-2013 Evgeny Prilepin 
    % ---------------------------------------------------------------------
    
    
    properties (GetAccess = public, SetAccess = ?signals.Receiver)
        
        % Отправитель сигнала если сигнал не анонимный
        %
        % @type signals.Sender
        Sender
        
        % Сигнал, который был принят приёмником
        %
        % @type signals.Signal
        Signal
        
        % Приёмник, который принял сигнал
        %
        % @type signals.Receiver
        Receiver
        
    end
    
    
    methods (Access = private)
        
        function self = ReceivingContext()
            % Private constructor
        end
        
    end
    
    
    methods (Access = {?signals.Receiver})
        
        function setData(self, signal, receiver)
            % Set up context data
            
            self.Sender = signal.Sender;
            self.Signal = signal;
            self.Receiver = receiver;
        end
        
        function clear(self)
            % Clears current context
            
            self.Sender = [];
            self.Signal = [];
            self.Receiver = [];
        end
        
    end
    
    
    methods (Static, Access = public)
        
        function context = getContext()
            % Returns singleton instance of ReceivingContext
            
            persistent instance

            if (isempty(instance) || ~isvalid(instance))
                instance = signals.ReceivingContext();
            end

            context = instance;
        end
        
    end
    
end % ReceivingContext
