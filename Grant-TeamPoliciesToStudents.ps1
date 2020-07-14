# Admin Login
# Login, falls noch keine Session besteht
$login = Read-Host 'Login to Microsoft 365 ? [Y/N]'
if($login -eq 'y' -or $login -eq 'Y')
    {
        $Cred = Get-Credential # Nutzeranmeldung

        Write-Output "Connect to Azure AD..."
        Connect-AzureAD -Credential $Cred

        Write-Output "Connect to SkypeOnline..."
        Import-Module SkypeOnlineConnector
        # In der folgenden Zeile den Tenant Name eintragen ! Das ist der ".onmicrossoft.com" Name. 
        # Man findet ihn hier unter den Domains: https://admin.microsoft.com/AdminPortal/Home#/Domains
        $sfboSession = New-CsOnlineSession -Credential $Cred -OverrideAdminDomain “TENANTNAME.onmicrosoft.com” 
        Import-PSSession $sfboSession -AllowClobber
    }

# Erzeuge eine Array mit allen SuSAccounts
# Hier alle Logins der SuS in Hochkommata und kommagetrennt auflisten.
# Kein Komma nach dem letzten Eintrag.
$SuSArray = @(
    'student1@schuldomain.de',
    'student2@schuldomain.de',
    'student3@schuldomain.de'
    )

# SuSArray durchlaufen
foreach($SuSLoginName in $SuSArray)
{
    Write-Output "---"
    Write-Output "--- $SuSLoginName ---"
    Write-Output "---"

    # Teams Richtlinien zuweisen
    # Alle Varianten sind hier beschrieben: https://docs.microsoft.com/en-us/microsoftteams/policy-packages-edu
    # Die Pakete können hier verwaltet werden: https://admin.teams.microsoft.com/policy-packages

    # Besprechungsrichtlinie Education_SecondaryStudent
        Write-Output "Besprechungsrichtlinie setzen"
        Grant-CsTeamsMeetingPolicy -Identity $SuSLoginName -PolicyName "Education_SecondaryStudent"
    # Nachrichtenrichtlinie Education_SecondaryStudent
        Write-Output "Nachrichtenrichtlinie setzen"
        Grant-CsTeamsMessagingPolicy -Identity $SuSLoginName -PolicyName "Education_SecondaryStudent"
    # Liveereignisrichtlinie Education_SecondaryStudent
        Write-Output "Liveereignisrichtlinie setzen"
        Grant-CsTeamsMeetingBroadcastPolicy -Identity $SuSLoginName -PolicyName "Education_SecondaryStudent"
    # App-Einrichtungsrichtlinie Education_SecondaryStudent
        Write-Output "App-Einrichtungsrichtlinie setzen"
        Grant-CsTeamsAppSetupPolicy -Identity $SuSLoginName -PolicyName "Education_SecondaryStudent"
    # Anrufrichtlinie Education_SecondaryStudent
        Write-Output "Anrufrichtlinie setzen"
        Grant-CsTeamsCallingPolicy -Identity $SuSLoginName -PolicyName "Education_SecondaryStudent"
    # Teams-Richtlinie zu privaten Kanälen
    # Wer hier https://admin.teams.microsoft.com/policies/channels eine benutzerdefinierte Richtlinie erstellt hat,
    # um das Erstellen privater Kanäle für die SuS zu verhindern kann diese Richtlinie hier zuweisen.
    # In dem Fall muss der selbstgewählte Name der Richtlinie hier einsetzt werden.  
    # Falls nicht benötigt, einfach Zeile auskommentieren.
        Write-Output "TeamsKanal-Richtlinie setzen"
        Grant-CsTeamsChannelsPolicy -Identity $SuSLoginName -PolicyName "NameDerRichtlinie"      
}

# Logoff, falls Session nicht mehr benötigt wird.
$logoff = Read-Host 'Logoff from Microsoft 365 ? [Y/N]'
if($logoff -eq 'y' -or $login -eq 'Y')
    {
        Remove-PSSession $sfboSession # Disconnect SkypeOnline
        Disconnect-AzureAD            # Disconnect AzureAD
    }