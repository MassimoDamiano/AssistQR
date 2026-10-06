using AssistQR.Api.DTOs.ClassSession;
using AssistQR.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;




namespace AssistQR.Api.Controllers

{
    [ApiController]

    [Route("api/v1/classes")]
    public class ClassController : ControllerBase
    {
        private readonly IClassService _classService;

        public ClassController(IClassService classService)
        {
            _classService = classService;
        }

        [HttpPost()]
        [Authorize(Roles = "TEACHER")]
        public async Task<ActionResult<ClassResponse>> CreateClass([FromBody] CreateClassRequest request,
            CancellationToken cancellationToken)
        {
            var subjectClaim = User.FindFirstValue("sub");

            if (!int.TryParse(subjectClaim, out var userId) || userId <= 0)
            {
                return Unauthorized();
            }

            try
            {
                var classResponse = await _classService.CreateAsync(request, userId, cancellationToken);
                return StatusCode(StatusCodes.Status201Created, classResponse);
            }
            catch (KeyNotFoundException)
            {
                return NotFound("Subject not found.");

            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
            catch (InvalidOperationException)
            {
                return Conflict("Cannot create a class for an inactive subject.");
            }
            catch (ArgumentException exception)
            {
                return BadRequest(exception.Message);
            }




        }



        [HttpGet()]
        [Authorize(Roles = "TEACHER")]

        public async Task<ActionResult<IReadOnlyList<TeacherClassSummaryResponse>>> GetTeacherClassSummaries(CancellationToken cancellationToken)
        {
            var subjectClaim = User.FindFirstValue("sub");
            if (!int.TryParse(subjectClaim, out var userId) || userId <= 0)
            {
                return Unauthorized();
            }
            var summaries = await _classService.GetTeacherClassSummariesAsync(userId, cancellationToken);
            return Ok(summaries);

        }

        [HttpPost("{classSessionId:int}/qr")]
        [Authorize(Roles = "TEACHER")]
        public async Task<ActionResult<QrClassResponse>> GenerateQr(
            int classSessionId,
            [FromBody] GenerateQrRequest request,
            CancellationToken cancellationToken)
        {
            var userIdClaim = User.FindFirstValue("sub");
            if (!int.TryParse(userIdClaim, out var teacherId) || teacherId <= 0)
            {
                return Unauthorized();
            }

            try
            {
                var response = await _classService.CreateQrClassAsync(
                    classSessionId,
                    teacherId,
                    request,
                    cancellationToken);
                return Ok(response);
            }
            catch (KeyNotFoundException)
            {
                return NotFound("Class session not found.");
            }
            catch (UnauthorizedAccessException)
            {
                return Forbid();
            }
            catch (InvalidOperationException exception)
            {
                return Conflict(exception.Message);
            }
            catch (ArgumentException exception)
            {
                return BadRequest(exception.Message);
            }
        }


    }
}
