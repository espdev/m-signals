% Main page of M-Signals documentation
%
% @mainpage M-Signals - Mechanism "Signals and Slots" for MATLAB
%
%
% Introduction
% ------------
%   M-Signals is the implementation of the "Observer" pattern designed as
%   <a href="http://en.wikipedia.org/wiki/Signals_and_slots">Signals and Slots</a>.
% 
%   This approach is based on signals and slots or receivers' classes. 
%   It is possible to create the unlimited number of class instances.
%   Each signal can be connected to the unlimited number of receivers, and 
%   each receiver can receive several signals (the receiver can be connected 
%   to the unlimited number of signals).
%   When signals are emitted, they can transmit(arguments) associated with them. 
%
%   This mechanism is considered to be flexible in the object-oriented program 
%   development and design. It allows binding of different objects without the 
%   objects knowing anything about each other.
%
%   The implementation of the "Observer" pattern with signals-slots mechanism 
%   allows to minimize the repetitive code and reduce module coupling. 
%   "Signals and slots" are well-suited not only for the implementation of 
%   program logic with the Graphical User Interface (GUI), but also for 
%   program design with loose coupling between modules. 
%
%
% Key features of M-Signals
% -------------------------
%   - Signals can be anonymous or have a particular sender
%   - Signals' arguments can be passed as typed or untyped arguments.
%   - Signals in sender's class can be automatically created from the events
%   - Signal can be emitted directly or through the event notification
%   - Flexible exception handling in slots includes the detailed exception output.
%   - API classes, similar to API classes in Qt library, 
%     are more visual and convenient than the event mechanism in MATLAB API
%   - Non-anonymous signals can be blocked by a sender
%   - Each signal can be enabled and disabled individually
%   - Each receiver can be enabled and disabled individually.
%
%
% Signal
% ------
%   Class Signal implements signal functionality. In M-Signals implementation
%   signals can be anonymous or have a sender. Only classes inherited from 
%   class Sender can send signals.  
%   
%   Signal can be emitted without any arguments, or with any number of 
%   arguments, or if there are mandatory specified arguments.
%   In some cases it is useful to control the emitted arguments.
%   
%   It is possible to emit a signal, using MATLAB event mechanism 
%   (event notification) or bypassing the event mechanism and directly 
%   calling Callback function of slots. 
%
%
% Receiver
% --------
%   Class Receiver implements slot (receiver) functionality. 
%   Receiver is able to receive several signals. If the callback-function 
%   receives fewer arguments than the signal emits, extra arguments are 
%   simply ignored. 
%
%   This entity has been added to M-Signals to ensure convenience and 
%   provide control. 
%   This entity has been added to M-Signals, because MATLAB function handles 
%   are not objects and the work with them does not fit in paradigm
%   of object-oriented programming.
%
%
% Sender
% ------
%   Class Sender implements sender functionality. Class implements some 
%   methods and a specific type of behavior. Any class inherited from 
%   Sender class is considered to be a sender of signals.
%
%   Class Sender adds the following options to the MATLAB handle classes:
%   - Dynamic addition and removal of signals. Signals are added 
%     as dynamic fields (Dynamic properties).
%   - Event-driven signals. The events of a class can be converted into
%     signals and added to sender's object as dynamic properties.
%   - Signal control. Signals can be blocked and unblocked by a sender.
%
%
% ErrorHandler
% ------------
%   Class enables the exceptions handling, occurring in the receivers 
%   during signals generation. It defines the method "process" that is called 
%   if the exception appears. Classes Signal and Receiver can use
%   ErrorHandler instances independently.
%
%   For exception handling it is necessary to create user classes inherited 
%   from ErrorHandler, override and implement the method "process" and assign 
%   instances for signals or receivers.
%
%
% @authors Evgeny Prilepin <esp.home@gmail.com>
%
% @copyright 2011-2013 Evgeny Prilepin
%
%
% @example UicontrolOnSignals.m
%
