function updateCountdown(elementId) {
    const element = document.getElementById(elementId);
    if (!element) return;

    const data = JSON.parse(element.getAttribute('data-countdown'));
    const dueDate = new Date(data.dueDate);
    const uaeOffset = data.uaeOffset;

    function calculateTimeRemaining() {
        const now = new Date();
        const utcNow = new Date(now.getTime() + now.getTimezoneOffset() * 60000);
        const uaeNow = new Date(utcNow.getTime() + (uaeOffset * 60 * 60 * 1000));
        const uaeDueDate = new Date(dueDate.getTime() + (uaeOffset * 60 * 60 * 1000));
        
        if (uaeNow > uaeDueDate) {
            element.textContent = 'Expired';
            element.closest('.assignment-status').querySelector('.status-badge').className = 'badge bg-danger status-badge';
            element.closest('.assignment-status').querySelector('.status-badge').textContent = 'Expired';
            return;
        }

        const diff = uaeDueDate - uaeNow;
        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const seconds = Math.floor((diff % (1000 * 60)) / 1000);

        element.textContent = `${days}d ${hours}h ${minutes}m ${seconds}s`;
    }

    // Update immediately and then every second
    calculateTimeRemaining();
    setInterval(calculateTimeRemaining, 1000);
} 