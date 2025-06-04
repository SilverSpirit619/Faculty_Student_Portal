// Please see documentation at https://docs.microsoft.com/aspnet/core/client-side/bundling-and-minification
// for details on configuring this project to bundle and minify static web assets.

// Write your JavaScript code.

// AJAX Loading Utilities
const ajaxLoader = {
    show: function() {
        if (!document.getElementById('ajax-loader')) {
            const loader = document.createElement('div');
            loader.id = 'ajax-loader';
            loader.innerHTML = `
                <div class="loading-overlay">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>`;
            document.body.appendChild(loader);
        }
        document.getElementById('ajax-loader').style.display = 'block';
    },
    
    hide: function() {
        const loader = document.getElementById('ajax-loader');
        if (loader) {
            loader.style.display = 'none';
        }
    }
};

// AJAX Request Helper
async function ajaxRequest(url, options = {}) {
    try {
        ajaxLoader.show();
        const response = await fetch(url, {
            ...options,
            headers: {
                ...options.headers,
                'X-Requested-With': 'XMLHttpRequest'
            }
        });
        
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('AJAX Error:', error);
        throw error;
    } finally {
        ajaxLoader.hide();
    }
}

// Toast Notification
function showToast(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                ${message}
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    `;
    
    const container = document.getElementById('toast-container') || (() => {
        const div = document.createElement('div');
        div.id = 'toast-container';
        div.className = 'toast-container position-fixed bottom-0 end-0 p-3';
        document.body.appendChild(div);
        return div;
    })();
    
    container.appendChild(toast);
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    toast.addEventListener('hidden.bs.toast', () => {
        toast.remove();
    });
}

// Timer Utilities
function updateTimer(element, dueDate) {
    const now = new Date().getTime();
    const due = new Date(dueDate).getTime();
    const distance = due - now;

    if (distance < 0) {
        element.innerHTML = '<span class="badge bg-danger">Expired</span>';
        return false;
    }

    const days = Math.floor(distance / (1000 * 60 * 60 * 24));
    const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((distance % (1000 * 60)) / 1000);

    let timerText = '';
    if (days > 0) timerText += `${days}d `;
    if (hours > 0) timerText += `${hours}h `;
    if (minutes > 0) timerText += `${minutes}m `;
    timerText += `${seconds}s`;

    element.innerHTML = `<span class="badge bg-${getTimerBadgeClass(distance)}">${timerText}</span>`;
    return true;
}

function getTimerBadgeClass(timeLeft) {
    const days = timeLeft / (1000 * 60 * 60 * 24);
    if (days <= 1) return 'danger';    // Less than 1 day
    if (days <= 3) return 'warning';   // Less than 3 days
    return 'success';                  // More than 3 days
}

function initializeTimers() {
    const timerElements = document.querySelectorAll('[data-timer]');
    timerElements.forEach(element => {
        const dueDate = element.getAttribute('data-timer');
        updateTimer(element, dueDate);
        const timerId = setInterval(() => {
            const shouldContinue = updateTimer(element, dueDate);
            if (!shouldContinue) {
                clearInterval(timerId);
            }
        }, 1000);
        element.setAttribute('data-timer-id', timerId);
    });
}

// Clean up timers when page changes
window.addEventListener('unload', () => {
    const timerElements = document.querySelectorAll('[data-timer]');
    timerElements.forEach(element => {
        const timerId = element.getAttribute('data-timer-id');
        if (timerId) {
            clearInterval(parseInt(timerId));
        }
    });
});
