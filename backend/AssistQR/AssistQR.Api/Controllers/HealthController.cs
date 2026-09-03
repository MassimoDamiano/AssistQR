using Microsoft.AspNetCore.Mvc;


namespace AssistQR.Api.Controllers
{
    [ApiController]
    [Route("api/v1/health")]
    
    public class HealthController : ControllerBase
    {
        [HttpGet]
        public ActionResult CheckHealth()
        {
            return Ok(new { status = "Healthy" });
        }
    }
}
