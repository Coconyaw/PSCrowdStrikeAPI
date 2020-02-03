$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.','.'
. "$here\$sut"
. ./Invoke-CSRestMethod.ps1

$IdsRes = Get-Content ./testRes_ids_Search-CSDetection.json | ConvertFrom-Json
$DetailRes = Get-Content ./testRes_detail_Search-CSDetection.json | ConvertFrom-Json
$idSearchUri = "/detects/queries/detects/v1"
$detailSearchUri = "/detects/entities/summaries/GET/v1"

Describe "Search-CSDetection" {
  It "q = 'Test' , expect call Search-CSDetectionDetail one times" {
    $q = @{ q = "Test" }
    Mock Invoke-CSRestMethod { return $IdsRes.resources } `
       -Verifiable `
       -ParameterFilter { $Uri -eq $idSearchUri; $Method -eq "GET"; $Endpoint -eq $idSearchUri; $Body -eq $q } -Scope It
    Mock Search-CSDetectionDetail { return $true } -Verification

    Search-CSDetection -q "test"
    Assert-MockCalled Search-CSDetectionDetail -Exactly 1
  }

  It "q = 'No ids', expect Error of 'No detection id'" {
    Mock Invoke-CSRestMethod { return $null } `
       -Verifiable `
       -ParameterFilter { $Uri -eq $idSearchUri; $Method -eq "GET"; $Endpoint -eq $idSearchUri; $Body -eq $q } -Scope It

    { Search-CSDetection -q "No ids" } | Should Throw "Search-CSDetection: No detection id"
  }
}

Describe "Search-CSDetectionIds" {
  It "q = 'Test' , expect array of id" {
    $q = @{ q = "Test" }
    Mock Invoke-CSRestMethod { return $IdsRes.resources } `
       -Verifiable `
       -ParameterFilter { $Uri -eq $idSearchUri; $Method -eq "GET"; $Endpoint -eq $idSearchUri; $Body -eq $q } -Scope It

    Search-CSDetectionIds -q "test" | Should Be $IdsRes.resources
  }

  It "q = 'No ids', expect null" {
    Mock Invoke-CSRestMethod { return $null } `
       -Verifiable `
       -ParameterFilter { $Uri -eq $idSearchUri; $Method -eq "GET"; $Endpoint -eq $idSearchUri; $Body -eq $q } -Scope It

    Search-CSDetectionIds -q "No ids" | Should Be $null
  }
}

Describe "Search-CSDetectionDetail" {
  It "Param array of id, expect detection detail" {
    $q = $IdsRes.resources
    Mock Invoke-CSRestMethod { return $DetailRes.resources } `
       -Verifiable `
       -ParameterFilter { $Uri -eq $idSearchUri; $Method -eq "POST"; $Endpoint -eq $detailSearchUri; $Body -eq $q } -Scope It

    Search-CSDetectionDetail $q | Should Be $DetailRes.resources
  }
}
