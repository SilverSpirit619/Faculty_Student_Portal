function initializeGrading() {
    const gradeForm = document.getElementById('gradeSubmissionForm');
    if (!gradeForm) return;

    gradeForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const formData = {
            submissionId: parseInt(gradeForm.querySelector('[name="SubmissionId"]').value),
            assignmentId: parseInt(gradeForm.querySelector('[name="AssignmentId"]').value),
            studentId: parseInt(gradeForm.querySelector('[name="StudentId"]').value),
            comments: gradeForm.querySelector('[name="Comments"]').value,
            grades: []
        };

        // Collect all criteria grades
        const criteriaRows = gradeForm.querySelectorAll('.criteria-row');
        criteriaRows.forEach(row => {
            formData.grades.push({
                criteriaId: parseInt(row.querySelector('[name="CriteriaId"]').value),
                criteriaName: row.querySelector('[name="CriteriaName"]').value,
                score: parseFloat(row.querySelector('[name="Score"]').value),
                maxScore: parseFloat(row.querySelector('[name="MaxScore"]').value)
            });
        });

        try {
            const response = await fetch('/Faculty/SubmitGrade', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'RequestVerificationToken': document.querySelector('input[name="__RequestVerificationToken"]').value
                },
                body: JSON.stringify(formData)
            });

            const result = await response.json();
            
            if (result.success) {
                showNotification('success', result.message);
                // Update the submission status in the UI
                const submissionRow = document.querySelector(`[data-submission-id="${formData.submissionId}"]`);
                if (submissionRow) {
                    submissionRow.querySelector('.grade-status').textContent = 'Graded';
                    submissionRow.querySelector('.grade-status').className = 'badge bg-success grade-status';
                }
                // Close the modal if using Bootstrap modal
                const modal = bootstrap.Modal.getInstance(document.getElementById('gradeModal'));
                if (modal) {
                    modal.hide();
                }
                // Reload the page after a short delay to show updated grades
                setTimeout(() => {
                    window.location.reload();
                }, 1500);
            } else {
                showNotification('error', result.message);
            }
        } catch (error) {
            showNotification('error', 'An error occurred while submitting grades');
            console.error('Error:', error);
        }
    });
}

function showNotification(type, message) {
    const notificationDiv = document.createElement('div');
    notificationDiv.className = `alert alert-${type === 'success' ? 'success' : 'danger'} notification-popup`;
    notificationDiv.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 9999;
        padding: 15px;
        border-radius: 5px;
        animation: slideIn 0.5s ease-out;
    `;
    notificationDiv.innerHTML = message;
    document.body.appendChild(notificationDiv);

    // Add the CSS animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
        @keyframes fadeOut {
            from { opacity: 1; }
            to { opacity: 0; }
        }
    `;
    document.head.appendChild(style);

    // Remove the notification after 3 seconds
    setTimeout(() => {
        notificationDiv.style.animation = 'fadeOut 0.5s ease-out';
        setTimeout(() => {
            document.body.removeChild(notificationDiv);
        }, 500);
    }, 3000);
}

// Initialize when the DOM is loaded
document.addEventListener('DOMContentLoaded', initializeGrading); 