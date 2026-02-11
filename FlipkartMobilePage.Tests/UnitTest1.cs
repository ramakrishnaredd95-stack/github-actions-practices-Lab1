using Xunit;
using FlipkartMobilePage.Controllers;
using Microsoft.AspNetCore.Mvc;

namespace FlipkartMobilePage.Tests;

public class FlipkartControllerTests
{
    [Fact]
    public void Index_ReturnsViewResult()
    {
        // Arrange
        var controller = new FlipkartController();

        // Act
        var result = controller.Index();

        // Assert
        Assert.IsType<ViewResult>(result);
    }

    [Fact]
    public void Products_ReturnsViewResult_WithProducts()
    {
        // Arrange
        var controller = new FlipkartController();

        // Act
        var result = controller.Products("mobiles");

        // Assert
        var viewResult = Assert.IsType<ViewResult>(result);
        var model = Assert.IsAssignableFrom<IEnumerable<object>>(viewResult.ViewData.Model);
        Assert.NotEmpty(model);
    }
}
