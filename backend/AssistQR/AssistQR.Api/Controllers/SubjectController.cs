using Microsoft.AspNetCore.Mvc;
using AssistQR.Api.DTOs.Subjects;
using AssistQR.Api.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace AssistQR.Api.Controllers
{
    [ApiController]
    [Route("api/v1/subjects")]

    public class SubjectController : ControllerBase
    {
        private readonly ISubjectService _subjectService;
        public SubjectController(ISubjectService subjectService)
        {
            _subjectService = subjectService;
        }



        [HttpPost]
        [Authorize(Roles = "TEACHER")]
        public async Task<ActionResult<SubjectResponse>> Create([FromBody] CreateSubjectRequest request, CancellationToken cancellationToken)
        {
            var subjectId = User.FindFirstValue("sub");
            if (!int.TryParse(subjectId, out var teacherId) || teacherId <= 0)
            {
                return Unauthorized();
            }
            var subject = await _subjectService.CreateAsync(
                request,
                teacherId,
                cancellationToken);

            return StatusCode(StatusCodes.Status201Created, subject);
        }

        [HttpGet]
        [Authorize(Roles = "TEACHER")]
        public async Task<ActionResult<IReadOnlyList<SubjectResponse>>> GetByTeacherId(CancellationToken cancellationToken)
        {
            var subjectId = User.FindFirstValue("sub");
            if (!int.TryParse(subjectId, out var teacherId) || teacherId <= 0)
            {
                return Unauthorized();
            }
            var subjects = await _subjectService.GetByTeacherIdAsync(teacherId, cancellationToken);
            return Ok(subjects);
        }

    }
}
