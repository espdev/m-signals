classdef UicontrolOnSignals < hgsetget & signals.Sender
    % Класс реализует uicontrol с использованием сигналов
    %
    % Description:
    %   Класс демонстрирует работу с сигналами на примере uicontrol.
    %   Класс является обёрткой над uicontrol и определяет сигналы, которые
    %   будут испускаться всякий раз при возникновении событий, связанных с 
    %   экземпляром uicontrol. 
    %
    % Uicontrol Signals:
    %   Action привязан к "Callback"
    %   Create привязан к "CreateFcn"
    %   Delete привязан к "DeleteFcn"
    %   ButtonDown привязан к "ButtonDownFcn"
    %   KeyPress привязан к "KeyPressFcn"
    %
    % Example:
    %   % Create Instance of PushButton
    %   pb = UicontrolOnSignals('Style', 'PushButton', 'String', 'Click Me!', 'Position', [20 20 100 30])
    %
    %   % Connect "Action" signal to two slots
    %   pb.Action.connect(@(src) fprintf('slot 1: "String": %s\n', get(src, 'String')))
    %   pb.Action.connect(@(src) fprintf('slot 2: "Enable": %s\n', get(src, 'Enable')))
    %
    %   pb.KeyPress.connect(@(src) fprintf('slot 3: "KeyInfo":\n'))
    %   pb.KeyPress.connect(@(src, evnt) disp(evnt))
    %
    
    properties (GetAccess = public, SetAccess = private)
        
        Action          % Signal for Callback
        Create          % Signal for CreateFcn
        Delete          % Signal for DeleteFcn
        ButtonDown      % Signal for ButtonDownFcn
        KeyPress        % Signal for KeyPressFcn
        
    end
    
    properties (GetAccess = public, SetAccess = private)
        
        UHandle         % Handle on UICONTROL instance
        
    end
    
    
    methods
        
        function self = UicontrolOnSignals(varargin)
            % Constructor
            
            % Create Signals          "Sender", "Required emitted arguments"
            %                                 |  source   | eventdata
            self.Action = signals.Signal(self, {'double'}, {});
            self.Create = signals.Signal(self, {'double'}, {});
            self.Delete = signals.Signal(self, {'double'}, {});
            self.ButtonDown = signals.Signal(self, {'double'}, {});
            self.KeyPress = signals.Signal(self, {'double'}, {});
            
            % Create Uicontrol
            self.UHandle = uicontrol(varargin{:});
            
            % Binding uicontrol actions to signals
            set(self.UHandle, ...
                'Callback', {@(src, evnt) self.Action.emit(src, evnt)}, ...
                'CreateFcn', {@(src, evnt) self.Create.emit(src, evnt)}, ...
                'DeleteFcn', {@(src, evnt) self.Delete.emit(src, evnt)}, ...
                'ButtonDownFcn', {@(src, evnt) self.ButtonDown.emit(src, evnt)}, ...
                'KeyPressFcn', {@(src, evnt) self.KeyPress.emit(src, evnt)});
            
            % Internal connections
            self.Delete.connect(@() delete(self))
        end
        
        function varargout = get(self, varargin)
            % HG Getter
            if (nargout > 0)
                varargout{1} = get(self.UHandle, varargin{:});
            else
                if (nargin < 2)
                    get(self.UHandle, varargin{:});
                else
                    varargout{1} = get(self.UHandle, varargin{:});
                end
            end
        end
        
        function set(self, varargin)
            % HG Setter
            set(self.UHandle, varargin{:});
        end
        
    end
    
end
