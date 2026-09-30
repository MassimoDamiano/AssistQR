using AssistQR.Api.DTOs.Subjects;
using AssistQR.Api.Services;
using System;
using AssistQR.Api.Repositories.Interfaces; 
using AssistQR.Api.Models;

namespace AssistQR.Api.Tests.Services;
public class SubjectServiceTests
{

    private sealed class FakeSubjectRepository : ISubjectRepository
    {
        public Task<int> CreateSubjectAsync(
            string name,
            int teacherId,
            string? description,
            CancellationToken cancellationToken)
        {
            return Task.FromResult(42);
        }
        public Task<IReadOnlyList<Subject>> GetByTeacherIdAsync(
    int teacherId,
    CancellationToken cancellationToken)
        {
            return Task.FromResult<IReadOnlyList<Subject>>(
                Array.Empty<Subject>());
        }
    }


    [Fact]
    
    public async Task CreateAsync_WhenTeacherIdIsZero_ThrowsArgumentOutOfRangeException()
    {

        // Arrange
        ISubjectRepository subjectRepository = new FakeSubjectRepository();
        SubjectService subjectService = new SubjectService(subjectRepository);
        CreateSubjectRequest subjectRequest = new CreateSubjectRequest();

        // Act & Assert
        
        var exception = await Assert.ThrowsAsync<ArgumentOutOfRangeException>(async () =>
        {
            await subjectService.CreateAsync(subjectRequest, 0, CancellationToken.None);
        });
        Assert.Equal("teacherId", exception.ParamName);
    }

    [Fact]
    public async Task CreateAsync_WhenValid_ReturnsSubjectResponse()
    {
        // Arrange
        ISubjectRepository subjectRepository = new FakeSubjectRepository();
        SubjectService subjectService = new SubjectService(subjectRepository);
        CreateSubjectRequest subjectRequest = new CreateSubjectRequest{ Name = "Matematicas", Description = "Primer año" };

        // Act
        var result = await subjectService.CreateAsync(subjectRequest, 1, CancellationToken.None);

        // Assert
        Assert.Equal(42, result.Id);
        Assert.Equal(1, result.TeacherId);
        Assert.True(result.IsActive);
        Assert.Equal("Matematicas", result.Name);
        Assert.Equal("Primer año", result.Description);
    }
    [Fact]
    public async Task CreateAsync_WhenNameIsWhitespace_ThrowsArgumentException()
    {
        // Arrange
        ISubjectRepository subjectRepository = new FakeSubjectRepository();
        SubjectService subjectService = new SubjectService(subjectRepository);
        CreateSubjectRequest subjectRequest = new CreateSubjectRequest { Name = "   ", Description = "Primer año", };
        // Act

        // Assert
        await Assert.ThrowsAsync<ArgumentException>(async () =>
        {
            await subjectService.CreateAsync(subjectRequest, 1, CancellationToken.None);
        });
    }

    
   

}
