using Microsoft.AspNetCore.Mvc;
using AssistQR.Api.DTOs.Subjects;
using AssistQR.Api.Services.Interfaces;

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


       
    }
}
