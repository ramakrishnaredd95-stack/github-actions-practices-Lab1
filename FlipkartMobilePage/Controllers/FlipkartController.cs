using Microsoft.AspNetCore.Mvc;
using FlipkartMobilePage.Models;

namespace FlipkartMobilePage.Controllers
{
    public class FlipkartController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }

        public IActionResult Products(string category = "mobiles")
        {
            ViewBag.Category = category;
            var products = GetProducts(category);
            return View(products);
        }

        public IActionResult ProductDetails(int id)
        {
            var product = GetProductById(id);
            return View(product);
        }

        private List<Product> GetProducts(string category)
        {
            // Sample product data
            return new List<Product>
            {
                new Product { Id = 1, Name = "Samsung Galaxy S24 Ultra", Price = 124999, Rating = 4.5, Image = "/images/samsung-s24.jpg", Category = "mobiles" },
                new Product { Id = 2, Name = "iPhone 15 Pro Max", Price = 159900, Rating = 4.7, Image = "/images/iphone-15.jpg", Category = "mobiles" },
                new Product { Id = 3, Name = "OnePlus 12", Price = 64999, Rating = 4.4, Image = "/images/oneplus-12.jpg", Category = "mobiles" },
                new Product { Id = 4, Name = "Google Pixel 8 Pro", Price = 106999, Rating = 4.6, Image = "/images/pixel-8.jpg", Category = "mobiles" },
                new Product { Id = 5, Name = "Xiaomi 14 Pro", Price = 79999, Rating = 4.3, Image = "/images/xiaomi-14.jpg", Category = "mobiles" },
                new Product { Id = 6, Name = "Vivo X100 Pro", Price = 89999, Rating = 4.5, Image = "/images/vivo-x100.jpg", Category = "mobiles" }
            };
        }

        private Product GetProductById(int id)
        {
            var products = GetProducts("mobiles");
            return products.FirstOrDefault(p => p.Id == id) ?? products.First();
        }
    }
}
