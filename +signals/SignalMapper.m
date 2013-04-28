classdef SignalMapper < signals.Sender
    % Выполняет сопоставление для сигналов и идентификаторов
    %
    % Description:
    %   Класс производит связывание (сопоставление) сигналов с идентификаторами.
    %   Идентификаторы могут быть любым типом данных MATLAB. При испускании
    %   сигнала, связанного с идентификатором, будет вызван сигнал Mapped
    %   класса SignalMapper с идентификатором в качестве аргумента.
    %
    %   Класс может быть полезен, когда необходимо "пробросить" сигналы от
    %   нескольких однотипных объектов в один приёмник, который будет
    %   производить какие-либо действия в зависимости от полученного
    %   идентификатора.
    %
    %
    % Example:
    % @code
    % m = signals.SignalMapper()
    % 
    % s1 = signals.Signal()
    % s2 = signals.Signal()
    %
    % s1.connect(m.Map)
    % s2.connect(m.Map)
    %
    % m.setMapping(s1, 1)
    % m.setMapping(s2, 'hello')
    %
    % m.Mapped.connect(@(id) disp(id))
    %
    % s1.emit()
    % s2.emit()
    % @endcode
    %
    %
    % See also: signals.Signal, signals.ReceivingContext
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
    
    
    properties (GetAccess = public, SetAccess = private)
        
        % Сигнал испускается при получении сигнала, который был установлен
        % как сопоставляемый
        %
        % Сигнал Mapped передаёт в качестве аргумента идентификатор,
        % сопоставленный тому сигналу, который был испущен.
        %
        % @type signals.Signal
        Mapped
        
        % Приёмник, который должен быть подключен к сопоставляемому сигналу
        %
        % @type signals.Receiver
        Map
        
    end
    
    properties (Access = private)
        
        Signals_
        Ids_
        
    end
    
    
    methods (Access = public)
        
        function self = SignalMapper()
            % Constructor создаёт экземпляр класса SignalMapper
            
            self.Mapped = signals.Signal(self, {});
            self.Map = signals.Receiver(@self.map, true);
            
            self.Signals_ = signals.Signal.empty();
            self.Ids_ = {};
        end
        
        function setMapping(self, signal, id)
            % Устанавливает сопоставление для указанных сигнала и идентификатора
            %
            % Description:
            %   Метод сопоставляет сигнал с идентификатором (делает
            %   отображение сигнала на иднетификатор). Если сопоставление
            %   уже существует, старый идентификатор будет заменён новым.
            %
            % Usage:
            %   obj.setMapping(signal, id)
            %
            % Parameters:
            %   signal: Экземпляр сигнала. @type signals.Signal
            %   id: Идентификатор. Любой MATLAB тип
            %
            % See also: getMapping
            %
            
            narginchk(3, 3)
            
            if ~isvalid(signal)
                return
            end
            
            validateattributes(signal, {'signals.Signal'}, {'scalar'}, ...
                mfilename('fullpath'), 'Signal', 1);
            
            validateattributes(id, {}, {'scalar'}, ...
                mfilename('fullpath'), 'Id', 2);
            
            [tf, ind] = ismember(signal, self.Signals_);
            
            if ~tf
                self.Signals_ = [self.Signals_, signal];
                ind = length(self.Signals_);
                
                addlistener(signal, 'ObjectBeingDestroyed', ...
                    @(src, ~) self.removeMapping(src));
            end
            
            self.Ids_{ind} = id;
        end
        
        function signal = getMapping(self, id)
            % Возвращает сопоставленный сигнал для указанного идентификатора
            %
            % Description:
            %   Метод возвращает сопоставленный экземпляр сигнала для
            %   указанного идентификатора. Если сопоставления не было
            %   найдено, возвращается пустое множество.
            %
            % Usage:
            %   signal = obj.getMapping(id)
            %
            % Parameters:
            %   id: Идентификатор. Любой MATLAB тип
            % 
            % Returns:
            %   signal: Экземпляр сигнала. @type signals.Signal
            %
            % See also: setMapping
            %
            
            narginchk(2, 2)
            
            validateattributes(id, {}, {'scalar'}, ...
                mfilename('fullpath'), 'Id', 1);
            
            [tf, ind] = ismember(id, self.Ids_);
            
            if tf
                signal = self.Signals_(ind);
            else
                signal = signals.Signal.empty();
            end
        end
        
        function removeMapping(self, signal)
            % Удаляет сопоставление для указанного сигнала
            %
            % Description:
            %   Метод удаляет сопоставление для указанного сигнала. 
            %   Если сопоставления не было найдено, ничего не делает.
            %
            %   Удаление сопоставления происходит автоматически если
            %   экземпляр сигнала, который был сопоставлен, разрушается.
            %
            % Usage:
            %   obj.removeMapping(signal)
            %
            % Parameters:
            %   signal: Экземпляр сигнала. @type signals.Signal
            %
            % See also: setMapping, getMapping
            %
            
            narginchk(2, 2)
            
            if ~isvalid(signal)
                return
            end
            
            validateattributes(signal, {'signals.Signal'}, {'scalar'}, ...
                mfilename('fullpath'), 'Signal', 1);
            
            [tf, ind] = ismember(signal, self.Signals_);
            
            if tf
                self.Signals_(ind) = [];
                self.Ids_(ind) = [];
            end
        end
        
    end % Public API Methods
    
    
    methods (Access = private)
        
        function map(self, varargin)
            
            context = signals.ReceivingContext.getContext();
            
            [tf, ind] = ismember(context.Signal, self.Signals_);
            
            if ~tf
                return
            end
            
            self.Mapped.emit(self.Ids_{ind})
        end
        
    end % Private Methods
    
end % signals.SignalMapper
