# Neo4j Aura Instance Status Checker
# Run this in PowerShell to verify your instance is accessible

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "NEO4J AURA INSTANCE CHECKER" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$host_name = "f957f86f.databases.neo4j.io"
$port = 7687

Write-Host "[1] Checking DNS Resolution..." -ForegroundColor Yellow
try {
    $ip = [System.Net.Dns]::GetHostAddresses($host_name)[0].IPAddressToString
    Write-Host "    OK DNS Resolved: $host_name -> $ip" -ForegroundColor Green
} catch {
    Write-Host "    FAILED DNS Resolution Failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[2] Testing TCP Connection (Port 7687)..." -ForegroundColor Yellow
$result = Test-NetConnection -ComputerName $host_name -Port $port -WarningAction SilentlyContinue

if ($result.TcpTestSucceeded) {
    Write-Host "    OK TCP Connection Successful" -ForegroundColor Green
    Write-Host "    Remote Address: $($result.RemoteAddress)" -ForegroundColor Gray
    Write-Host "    Port: $port" -ForegroundColor Gray
} else {
    Write-Host "    FAILED TCP Connection Failed" -ForegroundColor Red
    Write-Host "    This usually means:" -ForegroundColor Yellow
    Write-Host "      1. Neo4j Aura instance is PAUSED" -ForegroundColor Yellow
    Write-Host "      2. Firewall is blocking port 7687" -ForegroundColor Yellow
    Write-Host "      3. Instance is not running" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "    ACTION REQUIRED:" -ForegroundColor Red
    Write-Host "    -> Go to https://console.neo4j.io/" -ForegroundColor Cyan
    Write-Host "    -> Find instance: f957f86f" -ForegroundColor Cyan
    Write-Host "    -> Check status (should be Running)" -ForegroundColor Cyan
    Write-Host "    -> If Paused, click RESUME button" -ForegroundColor Cyan
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "RESULT: Neo4j Aura instance is ACCESSIBLE" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The network connection is working fine." -ForegroundColor Green
Write-Host "If Python still cannot connect, check:" -ForegroundColor Yellow
Write-Host "  1. Instance is in PAUSED state (check console)" -ForegroundColor Yellow
Write-Host "  2. Python SSL/certificate issue" -ForegroundColor Yellow
Write-Host "  3. Neo4j driver version compatibility" -ForegroundColor Yellow
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Restart the Python server" -ForegroundColor White
Write-Host "  2. It will try both neo4j+s and bolt+s automatically" -ForegroundColor White
Write-Host ""
