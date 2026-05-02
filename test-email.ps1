$body = @{
    lostUserEmail = "truptishetti89@gmail.com"
    lostUserName = "John Doe"
    foundUserEmail = "truptishetti89@gmail.com"
    foundUserName = "Jane Smith"
    itemName = "Blue Backpack"
    similarity = 0.92
} | ConvertTo-Json

Write-Host "Sending test request to http://localhost:4000/api/test-match-email..."
Write-Host "Body: $body"
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri 'http://localhost:4000/api/test-match-email' `
        -Method POST `
        -Headers @{'Content-Type' = 'application/json'} `
        -Body $body `
        -ErrorAction Stop
    
    Write-Host "✅ Success!"
    Write-Host $response.Content
}
catch {
    Write-Host "❌ Error: $_"
}
