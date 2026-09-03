using AssistQR.Api.Controllers;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

namespace AssistQR.Api.Tests;

public class HealthControllerTests
{
    [Fact]
    public void CheckHealth_WhenCalled_ReturnsOkWithHealthyStatus()
    {
        //Arrange

        var controller = new HealthController();

        //Act

        var result = controller.CheckHealth();

        //Assert

        var okResult = Assert.IsType<OkObjectResult>(result);
        using var document = JsonDocument.Parse(JsonSerializer.Serialize(okResult.Value));
        Assert.Equal(200, okResult.StatusCode);
        Assert.Equal("Healthy", document.RootElement.GetProperty("status").GetString());
    }
}
