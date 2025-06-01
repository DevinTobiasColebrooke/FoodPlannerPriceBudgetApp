# Implementation Steps for Specialized Components

## 1. Circular Timer Component

### CSS Implementation
1. Create `app/assets/styles/components/timer.css`:
```css
@import "tailwindcss";
@import "../../tailwind/application.css";

.circular-timer-demo { 
    width: 180px;
    height: 180px;
    border-radius: 50%;
    background-color: #fbfdf8;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    position: relative;
    border: 8px solid #f0f0f0;
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    margin: 2.5rem auto;
}

.timer-layer {
    position: absolute;
    width: 100%;
    height: 100%;
    border-radius: 50%;
}

.timer-layer-until-prep { z-index: 5; background-color: #5A6AD4; }
.timer-layer-prep { z-index: 4; background-color: #F0AB1F; }
.timer-layer-cook { z-index: 3; background-color: #FD7E14; }
.timer-layer-eat { z-index: 2; background-color: #5AD479; }

.circular-timer-demo .inner-circle { 
    width: calc(100% - 24px);
    height: calc(100% - 24px);
    background-color: #fbfdf8;
    border-radius: 50%;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    z-index: 6;
    text-align: center;
    box-shadow: inset 0 0 10px rgba(0,0,0,0.05);
}

.circular-timer-demo .time-left {
    font-size: 2.5rem;
    font-weight: 700;
    color: #333333;
    font-family: 'Poppins', sans-serif;
}

.circular-timer-demo .status {
    font-size: 0.8rem;
    color: #6B7280;
    margin-top: -0.25rem;
}
```

### JavaScript Implementation
1. Create `app/javascript/components/timer.js`:
```javascript
function runInteractiveTimer(timerId) {
    const timerContainer = document.getElementById(timerId);
    if (!timerContainer) return;

    const layers = {
        untilPrep: timerContainer.querySelector('.timer-layer-until-prep'),
        prep: timerContainer.querySelector('.timer-layer-prep'),
        cook: timerContainer.querySelector('.timer-layer-cook'),
        eat: timerContainer.querySelector('.timer-layer-eat'),
    };
    const timeLeftDisplay = timerContainer.querySelector('.time-left');
    const statusDisplay = timerContainer.querySelector('.status');

    const phases = [
        { name: "Until Prep", duration: 60 * 60 * 3 + 45 * 60, color: '#5A6AD4', layer: layers.untilPrep },
        { name: "Prep Time", duration: 60 * 7 + 30, color: '#F0AB1F', layer: layers.prep },
        { name: "Cook Time", duration: 60 * 3 + 45, color: '#FD7E14', layer: layers.cook },
        { name: "Meal Time", duration: 60 * 15, color: '#5AD479', layer: layers.eat }
    ];

    let currentPhaseIndex = 0;
    let _current_time_in_phase = phases[currentPhaseIndex].duration;
    let intervalId = null;

    function formatTime(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = seconds % 60;
        if (h > 0) {
            return `${h}:${m.toString().padStart(2, '0')}`;
        }
        return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    }

    function updateTimerDisplay() {
        timeLeftDisplay.textContent = formatTime(_current_time_in_phase);
        const currentPhase = phases[currentPhaseIndex];
        
        if (currentPhase.name === "Until Prep") {
            const now = new Date();
            const prepStartTime = new Date(now.getTime() + _current_time_in_phase * 1000);
            let hours = prepStartTime.getHours();
            const minutes = prepStartTime.getMinutes();
            const ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours ? hours : 12;
            const formattedMinutes = minutes < 10 ? '0' + minutes : minutes;
            statusDisplay.innerHTML = currentPhase.name + "<br>" + hours + ':' + formattedMinutes + ampm;
        } else {
            statusDisplay.textContent = currentPhase.name;
        }

        const _p = (_current_time_in_phase / currentPhase.duration) * 100;
        const percentageReceded = 100 - _p;

        currentPhase.layer.style.background = `conic-gradient(transparent 0% ${percentageReceded}%, ${currentPhase.color} ${percentageReceded}% 100%)`;

        for (let i = 0; i < currentPhaseIndex; i++) {
            phases[i].layer.style.background = `conic-gradient(transparent 0% 100%)`;
        }
        for (let i = currentPhaseIndex + 1; i < phases.length; i++) {
            phases[i].layer.style.background = phases[i].color;
        }
    }

    function advancePhase() {
        currentPhaseIndex++;
        if (currentPhaseIndex >= phases.length) {
            clearInterval(intervalId);
            statusDisplay.textContent = "All Done!";
            timeLeftDisplay.textContent = "00:00";
            Object.values(layers).forEach(layer => layer.style.background = 'transparent');
            return;
        }
        _current_time_in_phase = phases[currentPhaseIndex].duration;
        updateTimerDisplay();
    }

    function tick() {
        _current_time_in_phase--;
        if (_current_time_in_phase < 0) {
            advancePhase();
        } else {
            updateTimerDisplay();
        }
    }

    // Initialize
    currentPhaseIndex = 0;
    _current_time_in_phase = phases[currentPhaseIndex].duration;
    layers.untilPrep.style.background = phases[0].color;
    layers.prep.style.background = phases[1].color;
    layers.cook.style.background = phases[2].color;
    layers.eat.style.background = phases[3].color;
    updateTimerDisplay();

    if (intervalId) clearInterval(intervalId);
    intervalId = setInterval(tick, 1000);
}
```

## 2. Avatar Picker Component

### CSS Implementation
1. Create `app/assets/styles/components/avatar.css`:
```css
@import "tailwindcss";
@import "../../tailwind/application.css";

.avatar-item {
    transition: transform 0.2s ease-in-out, box-shadow 0.2s ease-in-out;
}

.avatar-item.selected {
    border-color: #5AD479;
    transform: scale(1.05);
    box-shadow: 0 0 0 3px #5AD479;
}

.avatar-item img {
    pointer-events: none;
}
```

### JavaScript Implementation
1. Create `app/javascript/components/avatar.js`:
```javascript
document.addEventListener('DOMContentLoaded', function() {
    const avatarItems = document.querySelectorAll('.avatar-item');
    avatarItems.forEach(item => {
        item.addEventListener('click', () => {
            avatarItems.forEach(el => el.classList.remove('selected'));
            item.classList.add('selected');
        });
    });

    const skipButton = document.getElementById('skip-avatar');
    if (skipButton) {
        skipButton.addEventListener('click', () => {
            window.location.href = 'dashboard.html';
        });
    }
});
```

## 3. Tidbit Carousel Component

### CSS Implementation
1. Create `app/assets/styles/components/carousel.css`:
```css
@import "tailwindcss";
@import "../../tailwind/application.css";

.tidbit-carousel-container {
    display: flex;
    overflow-x: auto;
    padding-bottom: 1rem;
    scroll-snap-type: x mandatory;
    -webkit-overflow-scrolling: touch;
}

.tidbit-carousel-container::-webkit-scrollbar {
    height: 8px;
}

.tidbit-carousel-container::-webkit-scrollbar-thumb {
    background: #BDDA83;
    border-radius: 4px;
}

.tidbit-item {
    flex: 0 0 auto;
    width: 140px;
    margin-right: 0.75rem;
    scroll-snap-align: start;
}

.tidbit-item img,
.tidbit-item .inline-svg-preview svg {
    width: 2rem;
    height: 2rem;
    margin-bottom: 0.25rem;
    object-fit: contain;
}
```

## 4. Progress Indicators Component

### CSS Implementation
1. Create `app/assets/styles/components/progress.css`:
```css
@import "tailwindcss";
@import "../../tailwind/application.css";

.progress-bar {
    width: 100%;
    background-color: #D1D5DB;
    border-radius: 9999px;
    height: 0.625rem;
}

.progress-bar-fill {
    background-color: #5AD479;
    height: 100%;
    border-radius: 9999px;
    transition: width 0.3s ease-in-out;
}

.step-progress {
    display: flex;
    align-items: center;
    width: 100%;
    text-align: center;
}

.step-progress-item {
    flex: 1;
    position: relative;
}

.step-progress-item::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    width: 100%;
    height: 2px;
    background-color: #5AD479;
    z-index: 1;
}

.step-progress-item:last-child::after {
    display: none;
}

.step-progress-item.completed::after {
    background-color: #5AD479;
}

.step-progress-item.current::after {
    background-color: #D1D5DB;
}
```

## 5. Update Application CSS

1. Update `app/assets/tailwind/application.css` to import component styles:
```css
@import "tailwindcss";
@import "../styles/components/timer.css";
@import "../styles/components/avatar.css";
@import "../styles/components/carousel.css";
@import "../styles/components/progress.css";

/* Rest of your global styles */
```

## 6. Update JavaScript Entry Point

1. Update `app/javascript/application.js` to import component scripts:
```javascript
import "./components/timer"
import "./components/avatar"
```

## 7. Update Importmap Configuration

1. Update `config/importmap.rb` to pin the component JavaScript files:
```ruby
# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Pin specialized components
pin_all_from "app/javascript/components", under: "components"
```

## 8. Usage Examples

### Circular Timer
```html
<div class="circular-timer-demo" id="dashboardLiveTimer">
    <div class="timer-layer timer-layer-eat"></div>
    <div class="timer-layer timer-layer-cook"></div>
    <div class="timer-layer timer-layer-prep"></div>
    <div class="timer-layer timer-layer-until-prep"></div>
    <div class="inner-circle">
        <div class="time-left font-display-prototype">00:00</div>
        <div class="status">Loading...</div>
    </div>
</div>
```

### Avatar Picker
```html
<div class="grid grid-cols-3 gap-x-3 gap-y-4 px-2">
    <div class="avatar-item aspect-square rounded-full border-2 border-fp-neutral-medium p-0.5 bg-white cursor-pointer">
        <img src="../svgs/920999-avatar/svg/001-man.svg" alt="Man Avatar" class="w-full h-full object-contain rounded-full">
    </div>
    <!-- More avatar items -->
</div>
```

### Tidbit Carousel
```html
<div class="tidbit-carousel-container">
    <div class="tidbit-item bg-fp-neutral-lightest p-3 rounded-fp shadow-fp-card text-center flex flex-col items-center">
        <img src="../svgs/4285413-time-and-date/svg/007-timer.svg" alt="Prep Time" class="mx-auto">
        <p class="text-xs font-medium text-fp-neutral-darkest">Prep Time</p>
        <p class="text-sm font-semibold text-fp-primary-green mt-0.5">15 mins</p>
    </div>
    <!-- More tidbit items -->
</div>
```

### Progress Indicators
```html
<!-- Linear Progress -->
<div class="progress-bar">
    <div class="progress-bar-fill" style="width: 45%"></div>
</div>

<!-- Step Progress -->
<div class="step-progress">
    <div class="step-progress-item completed">
        <span class="step-number">1</span>
        <span class="step-label">Profile</span>
    </div>
    <div class="step-progress-item current">
        <span class="step-number">2</span>
        <span class="step-label">Allergies</span>
    </div>
    <div class="step-progress-item">
        <span class="step-number">3</span>
        <span class="step-label">Preferences</span>
    </div>
</div>
``` 