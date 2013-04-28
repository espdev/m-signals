classdef (Sealed) ReceivingContext < handle
    % ������������� ����������� ��������� ������ � ��������� ����� ��������
    %
    % Description:
    %   ����� ������������ ������ � ������ ��������� ����� ������� �
    %   callback-������� ��������, ���� � ���� ���� ���������
    %   ������������.
    %
    %   ��������� �������� ��������� ������:
    %   - ���������� �� ������� �����������, ���� ������ �� ��� ���������
    %     (������ �� ��������� �����������, ���� [] ��� ���������� �������)
    %   - ���������� �� ������� ������� (������ �� ��������� �������)
    %   - ���������� �� ������� �������� (������ �� ��������� ��������)
    %
    % @note
    % �� ������������� ������������ ������ ����� ��� ������ �������������,
    % �.�. ��� ������������� ����������� ����������� �������, ��������
    % ������������ ������ � ����� ��������� ������������� "�������� � ������".
    %
    % @warning
    % ������ ����� �������� Singleton-�������, �.�. ����������. ��� ������
    % ����� ��������� ������� ���������, ���������� � ����� ������ �����
    % ������������ ������ �������.
    %
    % @warning
    % ������� ������ ��������� ���������� ������ �� ����� ����������
    % callback-������� ��������. ������ ��������� ����� ������� �����
    % ����� ���������� ���������� callback-�������.
    %
    % Usage:
    % ��������������, ��� �������� ����� �������������� � callback-�������
    % ��������.
    % ������ �������������:
    %
    % @code
    % function someCallback()
    %     % Callback-������� ��������, ������� ����������� ��� ����� �������
    %
    %     % �������� ������� ������ ��������� ����� �������
    %     context = signals.ReceivingContext.getContext()
    %
    %     % ���������� �� �����������
    %     sender = context.Sender
    %     
    %     % ���������� � �������
    %     signal = context.Signal
    %
    %     % �����-�� ��������...
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
        
        % ����������� ������� ���� ������ �� ���������
        %
        % @type signals.Sender
        Sender
        
        % ������, ������� ��� ������ ���������
        %
        % @type signals.Signal
        Signal
        
        % �������, ������� ������ ������
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
