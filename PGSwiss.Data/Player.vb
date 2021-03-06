﻿Imports System.IO
Imports System.Xml.Serialization
Imports System.ComponentModel

Public Class doPlayer
    Implements INotifyPropertyChanged

    Private _Name As String
    Public Property Name As String
        Get
            Return _Name
        End Get
        Set(value As String)
            _Name = value
            OnPropertyChanged("Name")
        End Set
    End Property

    Private _Meta As String
    Public Property Meta As String
        Get
            If _Meta Is Nothing Then _Meta = ""
            Return _Meta
        End Get
        Set(value As String)
            _Meta = value
            OnPropertyChanged("Meta")
        End Set
    End Property

    Private _Faction As String
    Public Property Faction As String
        Get
            Return _Faction
        End Get
        Set(value As String)
            _Faction = value
            OnPropertyChanged("Faction")
        End Set
    End Property

    Public Property ByeVol As Boolean
    Public Property Drop As Boolean
    Public Property TourneyPoints As Integer

    Private _TotalTourneyPoints As Integer
    Public Property TotalTourneyPoints As Integer
        Get
            Return _TotalTourneyPoints
        End Get
        Set(value As Integer)
            _TotalTourneyPoints = value
            OnPropertyChanged("TotalTourneyPoints")
        End Set
    End Property

    Public Property StrengthOfSchedule As Integer
    Public Property PairedDownRound As Integer

    Private _ControlPoints As Integer
    Public Property ControlPoints As Integer
        Get
            Return _ControlPoints
        End Get
        Set(value As Integer)
            _ControlPoints = value
            OnPropertyChanged("ControlPoints")
        End Set
    End Property

    Public Property ArmyPointsDestroyed As Integer

    Public Property Rank As Integer

    Public Function Clone() As doPlayer
        Dim dopReturn As New doPlayer
        dopReturn.Faction = Me.Faction
        dopReturn.Meta = Me.Meta
        dopReturn.Name = Me.Name
        dopReturn.TourneyPoints = Me.TourneyPoints
        'dopReturn.Tables = Me.Tables
        'dopReturn.Opponents = Me.Opponents
        dopReturn.ByeVol = Me.ByeVol
        dopReturn.PairedDownRound = Me.PairedDownRound
        dopReturn.Caster1 = Me.Caster1
        dopReturn.Caster2 = Me.Caster2
        dopReturn.Theme1 = Me.Theme1
        dopReturn.Theme2 = Me.Theme1
        dopReturn.CCCode = Me.CCCode
        Return dopReturn
    End Function


    Public Property Opponents As New List(Of String)
    Public Property Tables As New List(Of Integer)

    Public Property Caster1 As String
    Public Property Theme1 As String
    Public Property Caster2 As String
    Public Property Theme2 As String
    Public Property CCCode As String



    ' Create the OnPropertyChanged method to raise the event 
    Protected Sub OnPropertyChanged(ByVal name As String)
        DirtyMonitor.IsDirty = True
        RaiseEvent PropertyChanged(Me, New PropertyChangedEventArgs(name))
    End Sub
    Public Event PropertyChanged(sender As Object, e As PropertyChangedEventArgs) Implements INotifyPropertyChanged.PropertyChanged

End Class

Public Class doPlayerCollection
    Inherits List(Of doPlayer)

    Public Sub load()
        Me.Clear()
        If IO.File.Exists("PlayerCollection.xml") Then
            Using objStreamReader As New StreamReader("PlayerCollection.xml")
                Dim x As New XmlSerializer(Me.GetType)
                Dim lst As New List(Of doPlayer)
                lst.AddRange(x.Deserialize(objStreamReader))
                Me.AddRange(From p In lst Order By p.Name)
            End Using
        End If
    End Sub

    Private _FailedSave As Boolean = False
    Public Sub Save()
        Try
            Using objStreamWriter As New StreamWriter("PlayerCollection.xml")
                Dim x As New XmlSerializer(Me.GetType)
                x.Serialize(objStreamWriter, Me)
            End Using
            _FailedSave = False
        Catch exc As System.IO.IOException
            If _FailedSave = False Then
                _FailedSave = True
                Save()
            End If
        End Try
    End Sub
End Class
