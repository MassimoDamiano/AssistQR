using AssistQR.Api.DTOs.Subjects;
using AssistQR.Api.Services;
using System;
using AssistQR.Api.Repositories.Interfaces; 

namespace AssistQR.Api.Tests.Services;
public class SubjectServiceTests
{

    private sealed class FakeSubjectRepository : ISubjectRepository
    {
        public int CallCount { get; private set; }
        public string? ReceivedName { get; private set; }
        public int? ReceivedTeacherId { get; private set; }
        public string? ReceivedDescription { get; private set; }

        public Task<int> CreateSubjectAsync(
            string name,
            int teacherId,
            string? description,
            CancellationToken cancellationToken)
        {
            CallCount++;
            ReceivedName = name;
            ReceivedTeacherId = teacherId;
            ReceivedDescription = description;
            return Task.FromResult(42);
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
        FakeSubjectRepository subjectRepository = new FakeSubjectRepository();
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
        Assert.Equal(1, subjectRepository.CallCount);
        Assert.Equal("Matematicas", subjectRepository.ReceivedName);
        Assert.Equal(1, subjectRepository.ReceivedTeacherId);
        Assert.Equal("Primer año", subjectRepository.ReceivedDescription);
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
