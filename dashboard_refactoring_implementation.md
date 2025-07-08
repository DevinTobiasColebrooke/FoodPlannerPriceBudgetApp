# Dashboard View Refactoring Implementation Guide

## Overview
This document outlines comprehensive refactoring opportunities for the dashboard view (`app/views/dashboard/show.html.erb`) to improve maintainability, performance, and adherence to Rails conventions.

## 1. Extract CSS to Proper Stylesheet Files

### Current Issue
The dashboard has 100+ lines of inline CSS in the `<style>` tag, making it difficult to maintain and reuse.

### Implementation Steps

#### Step 1: Create Dashboard Component Stylesheet
Create `app/assets/stylesheets/components/dashboard.css`:

```css
/* Dashboard Layout */
.main-dashboard-area { 
    flex-grow: 1; 
    overflow-y: auto; 
    padding: 1.5rem 1.5rem; 
}

/* Timer Components */
.conceptual-timer {
    width: 180px; 
    height: 180px; 
    border-radius: 50%; 
    background-color: #fbfdf8; 
    margin: 2.5rem auto;
    display: flex; 
    flex-direction: column; 
    align-items: center; 
    justify-content: center;
    position: relative; 
    border: 8px solid #f0f0f0; 
    box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}

.conceptual-timer .progress-segment { 
    position: absolute; 
    width: 100%; 
    height: 100%; 
    border-radius: 50%; 
    clip-path: polygon(50% 0%, 100% 0%, 100% 33%, 50% 33%); 
}

.conceptual-timer .prep { 
    background-color: #F0AB1F; 
    transform: rotate(0deg) scale(1.01); 
    z-index: 3; 
}

.conceptual-timer .cook { 
    background-color: #FD7E14; 
    transform: rotate(120deg) scale(1.01); 
    z-index: 2; 
}

.conceptual-timer .eat { 
    background-color: #5AD479; 
    transform: rotate(240deg) scale(1.01); 
    z-index: 1; 
}

.conceptual-timer .inner-circle { 
    width: calc(100% - 24px); 
    height: calc(100% - 24px); 
    background-color: #fbfdf8; 
    border-radius: 50%; 
    display: flex; 
    flex-direction: column; 
    align-items: center; 
    justify-content: center; 
    z-index: 4; 
    text-align: center; 
}

.conceptual-timer .time { 
    font-size: 2.5rem; 
    font-weight: 700; 
    color: #333333; 
    font-family: 'Poppins', sans-serif; 
}

.conceptual-timer .label { 
    font-size: 0.8rem; 
    color: #6B7280; 
    margin-top: -0.25rem; 
}

/* Circular Timer Demo */
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

.timer-layer-until-prep { 
    z-index: 5; 
    background-color: #5A6AD4; 
}

.timer-layer-prep { 
    z-index: 4; 
    background-color: #F0AB1F; 
}

.timer-layer-cook { 
    z-index: 3; 
    background-color: #FD7E14; 
}

.timer-layer-eat { 
    z-index: 2; 
    background-color: #5AD479; 
}

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

/* Meal Items */
.meal-item { 
    cursor: pointer; 
    transition: background-color 0.2s; 
}

.meal-item.current h3 { 
    font-size: 1.25rem; 
    color: #34C759; 
}

/* Eyebrow Buttons */
.eyebrow-buttons-container { 
    display: flex; 
    gap: 0.5rem; 
    overflow-x: auto; 
    padding: 0.5rem 0 1rem 0; 
    margin-bottom: 1rem; 
    -ms-overflow-style: none; 
    scrollbar-width: none; 
}

.eyebrow-buttons-container::-webkit-scrollbar { 
    display: none; 
}

.eyebrow-btn { 
    white-space: nowrap; 
}
```

#### Step 2: Update Application CSS
Add to `app/assets/stylesheets/application.css`:

```css
/*
 * This is a manifest file that'll be compiled into application.css.
 *
 * With Propshaft, assets are served efficiently without preprocessing steps. You can still include
 * application-wide styles in this file, but keep in mind that CSS precedence will follow the standard
 * cascading order, meaning styles declared later in the document or manifest will override earlier ones,
 * depending on specificity.
 *
 * Consider organizing styles into separate files for maintainability.
 */

@import "components/dashboard.css";
```

#### Step 3: Remove Inline Styles
Remove the entire `<style>` block from `app/views/dashboard/show.html.erb`.

## 2. Fix Mobile Responsiveness Issues

### Current Issues
- Fixed max-widths that don't adapt well to mobile
- Timer and nutrient stats section uses `flex gap-6` which may cause overflow
- Eyebrow buttons container could be better optimized for mobile

### Implementation Steps

#### Step 1: Update Container Layout
Replace the current container:

```html
<!-- Current problematic layout -->
<div class="w-full max-w-[430px] sm:max-w-sm md:max-w-md lg:max-w-lg xl:max-w-xl 2xl:max-w-2xl mx-auto bg-fp-body-bg flex flex-col min-h-screen shadow-xl">

<!-- Improved responsive layout -->
<div class="w-full max-w-md mx-auto bg-fp-body-bg flex flex-col min-h-screen shadow-xl">
```

#### Step 2: Make Timer Section Responsive
Update the timer and nutrient stats section:

```html
<!-- Current layout -->
<div class="flex gap-6">

<!-- Improved responsive layout -->
<div class="flex flex-col lg:flex-row gap-4 lg:gap-6">
    <div class="flex-shrink-0">
        <!-- Timer component -->
    </div>
    <div class="flex-1">
        <!-- Nutrient stats -->
    </div>
</div>
```

#### Step 3: Improve Eyebrow Buttons for Mobile
Add responsive classes to eyebrow buttons:

```html
<div class="eyebrow-buttons-container">
    <button class="eyebrow-btn bg-fp-primary-green text-white text-xs font-medium py-2 px-3 sm:px-4 rounded-full shadow-fp-cta">Start Next Meal</button>
    <button class="eyebrow-btn bg-fp-accent-blue text-white text-xs font-medium py-2 px-3 sm:px-4 rounded-full shadow-fp-cta">Scan Barcode</button>
    <button class="eyebrow-btn bg-white text-fp-neutral-text text-xs font-medium py-2 px-3 sm:px-4 rounded-full border border-fp-neutral-medium shadow-sm">Quick Add Item</button>
    <button class="eyebrow-btn bg-white text-fp-neutral-text text-xs font-medium py-2 px-3 sm:px-4 rounded-full border border-fp-neutral-medium shadow-sm">Browse Recipes</button>
</div>
```

## 3. Extract JavaScript to Separate Files

### Current Issue
200+ lines of JavaScript embedded in the view, making it difficult to maintain and test.

### Implementation Steps

#### Step 1: Create Timer Component
Create `app/javascript/components/timer.js`:

```javascript
// Timer Component
export class Timer {
    constructor(timerId) {
        this.timerContainer = document.getElementById(timerId);
        if (!this.timerContainer) return;

        this.layers = {
            untilPrep: this.timerContainer.querySelector('.timer-layer-until-prep'),
            prep: this.timerContainer.querySelector('.timer-layer-prep'),
            cook: this.timerContainer.querySelector('.timer-layer-cook'),
            eat: this.timerContainer.querySelector('.timer-layer-eat'),
        };
        this.timeLeftDisplay = this.timerContainer.querySelector('.time-left');
        this.statusDisplay = this.timerContainer.querySelector('.status');

        this.phases = [
            { name: "Until Prep", duration: 60 * 60 * 3 + 45 * 60, color: '#5A6AD4', layer: this.layers.untilPrep, nextLayerColor: '#F0AB1F' },
            { name: "Prep Time",  duration: 60 * 7 + 30, color: '#F0AB1F', layer: this.layers.prep, nextLayerColor: '#FD7E14' },
            { name: "Cook Time",  duration: 60 * 3 + 45, color: '#FD7E14', layer: this.layers.cook, nextLayerColor: '#5AD479' },
            { name: "Meal Time",  duration: 60 * 15, color: '#5AD479', layer: this.layers.eat, nextLayerColor: '#fbfdf8' }
        ];

        this.currentPhaseIndex = 0;
        this.currentTimeInPhase = this.phases[this.currentPhaseIndex].duration;
        this.intervalId = null;

        this.init();
    }

    formatTime(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const s = seconds % 60;
        if (h > 0) {
            const hoursString = h.toString();
            return `${hoursString}:${m.toString().padStart(2, '0')}`;
        }
        return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
    }

    updateTimerDisplay() {
        this.timeLeftDisplay.textContent = this.formatTime(this.currentTimeInPhase);

        const currentPhase = this.phases[this.currentPhaseIndex];
        if (currentPhase.name === "Until Prep") {
            const now = new Date();
            const prepStartTime = new Date(now.getTime() + this.currentTimeInPhase * 1000);

            let hours = prepStartTime.getHours();
            const minutes = prepStartTime.getMinutes();
            const ampm = hours >= 12 ? 'pm' : 'am';
            hours = hours % 12;
            hours = hours ? hours : 12;
            const formattedMinutes = minutes < 10 ? '0' + minutes : minutes;
            const targetTimeFormatted = hours + ':' + formattedMinutes + ampm;

            this.statusDisplay.innerHTML = currentPhase.name + "<br>" + targetTimeFormatted;
        } else {
            this.statusDisplay.textContent = currentPhase.name;
        }

        const percentage = (this.currentTimeInPhase / currentPhase.duration) * 100;
        const percentageReceded = 100 - percentage;

        currentPhase.layer.style.background = `conic-gradient(transparent 0% ${percentageReceded}%, ${currentPhase.color} ${percentageReceded}% 100%)`;

        for (let i = 0; i < this.currentPhaseIndex; i++) {
            this.phases[i].layer.style.background = `conic-gradient(transparent 0% 100%)`;
        }
        for (let i = this.currentPhaseIndex + 1; i < this.phases.length; i++) {
            this.phases[i].layer.style.background = this.phases[i].color;
        }
        if (this.currentPhaseIndex + 1 < this.phases.length) {
            this.phases[this.currentPhaseIndex + 1].layer.style.background = this.phases[this.currentPhaseIndex + 1].color;
        } else {
             if (percentage === 0) currentPhase.layer.style.background = `conic-gradient(transparent 0% 100%)`;
        }
    }

    advancePhase() {
        this.currentPhaseIndex++;
        if (this.currentPhaseIndex >= this.phases.length) {
            clearInterval(this.intervalId);
            this.statusDisplay.textContent = "All Done!";
            this.timeLeftDisplay.textContent = "00:00";
            Object.values(this.layers).forEach(layer => layer.style.background = 'transparent');
            return;
        }
        this.currentTimeInPhase = this.phases[this.currentPhaseIndex].duration;
        this.updateTimerDisplay();
    }

    tick() {
        this.currentTimeInPhase--;
        if (this.currentTimeInPhase < 0) {
            this.advancePhase();
        } else {
            this.updateTimerDisplay();
        }
    }

    init() {
        this.currentPhaseIndex = 0;
        this.currentTimeInPhase = this.phases[this.currentPhaseIndex].duration;
        this.layers.untilPrep.style.background = this.phases[0].color;
        this.layers.prep.style.background = this.phases[1].color;
        this.layers.cook.style.background = this.phases[2].color;
        this.layers.eat.style.background = this.phases[3].color;
        this.updateTimerDisplay();

        if (this.intervalId) clearInterval(this.intervalId);
        this.intervalId = setInterval(() => this.tick(), 1000);
    }
}
```

#### Step 2: Create Modal Component
Create `app/javascript/components/modals.js`:

```javascript
// Modal Component
export class Modal {
    constructor(modalId, triggerId, closeId) {
        this.modal = document.getElementById(modalId);
        this.trigger = document.getElementById(triggerId);
        this.closeBtn = document.getElementById(closeId);
        
        if (this.modal && this.trigger && this.closeBtn) {
            this.init();
        }
    }

    init() {
        this.trigger.addEventListener('click', () => this.open());
        this.closeBtn.addEventListener('click', () => this.close());
        
        // Close modal if clicked outside the content
        this.modal.addEventListener('click', (event) => {
            if (event.target === this.modal) {
                this.close();
            }
        });
    }

    open() {
        this.modal.classList.remove('hidden');
    }

    close() {
        this.modal.classList.add('hidden');
    }
}
```

#### Step 3: Create Main Dashboard JavaScript
Create `app/javascript/dashboard.js`:

```javascript
import { Timer } from './components/timer.js';
import { Modal } from './components/modals.js';

document.addEventListener('DOMContentLoaded', function() {
    // Initialize timer
    new Timer('dashboardLiveTimer');

    // Initialize modals
    new Modal('personalStatsPopup', 'profileStatsBtn', 'closeStatsPopupBtn');
    new Modal('fullDriReportModal', 'fullDriReportBtn', 'closeDriReportBtn');
});
```

#### Step 4: Update Import Map
Add to `config/importmap.rb`:

```ruby
pin "dashboard", preload: true
pin "components/timer", preload: true
pin "components/modals", preload: true
```

#### Step 5: Remove Inline JavaScript
Remove the entire `<script>` block from the view and add:

```erb
<%= javascript_import_module_tag "dashboard" %>
```

## 4. Use Rails Layout System Properly

### Current Issue
The view has its own complete HTML structure instead of using the existing mobile layout.

### Implementation Steps

#### Step 1: Remove Complete HTML Structure
Remove from `app/views/dashboard/show.html.erb`:
- `<!DOCTYPE html>`
- `<html>` tag
- `<head>` section
- `<body>` tag
- Closing `</html>` tag

#### Step 2: Use Mobile Layout
Add to the top of the view:

```erb
<% content_for :title, "Food Planner - Dashboard" %>

<% content_for :head do %>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Satisfy&display=swap" rel="stylesheet">
<% end %>
```

#### Step 3: Update Layout Reference
Ensure the controller uses the mobile layout:

```ruby
# app/controllers/dashboard_controller.rb
class DashboardController < ApplicationController
  layout 'mobile'
  
  def show
    # existing code
  end
end
```

## 5. Extract Reusable Components

### Current Issues
- Timer component is duplicated
- Modal components are hardcoded
- Meal items are repeated with similar structure

### Implementation Steps

#### Step 1: Create Timer Partial
Create `app/views/shared/_timer.html.erb`:

```erb
<div class="circular-timer-demo" id="<%= timer_id || 'dashboardLiveTimer' %>">
    <div class="timer-layer timer-layer-until-prep"></div>
    <div class="timer-layer timer-layer-prep"></div>
    <div class="timer-layer timer-layer-cook"></div>
    <div class="timer-layer timer-layer-eat"></div>
    <div class="inner-circle">
        <div class="time-left"><%= time_left || '03:45' %></div>
        <div class="status"><%= status || 'Until Prep' %></div>
    </div>
</div>
```

#### Step 2: Create Meal Item Partial
Create `app/views/shared/_meal_item.html.erb`:

```erb
<div class="meal-item <%= 'current' if current %> bg-<%= current ? 'fp-neutral-lightest' : 'white' %> p-4 rounded-fp shadow-fp-card mb-3 flex items-center space-x-4 <%= 'opacity-80' unless current %>">
    <%= image_tag meal.image_url, alt: meal.name, class: "w-16 h-16 rounded-md object-cover" %>
    <div class="flex-grow">
        <h3 class="font-<%= current ? 'semibold text-fp-primary-green-dark' : 'medium text-fp-neutral-text' %>"><%= meal.name %></h3>
        <p class="text-xs text-fp-neutral-text-light"><%= meal.meal_type %> - <%= meal.scheduled_time %></p>
        <% if meal.rating %>
            <div class="flex items-center mt-1">
                <svg class="w-3 h-3 text-fp-accent-yellow mr-1" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"></path>
                </svg>
                <span class="text-xs text-fp-neutral-text-light"><%= meal.rating %> (<%= meal.review_count %> reviews)</span>
            </div>
        <% end %>
    </div>
    <svg class="w-<%= current ? '6' : '5' %> h-<%= current ? '6' : '5' %> text-fp-neutral-medium" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
    </svg>
</div>
```

#### Step 3: Create Nutrient Stats Partial
Create `app/views/shared/_nutrient_stats.html.erb`:

```erb
<div class="flex-1 bg-white p-4 rounded-fp shadow-fp-card">
    <h2 class="text-lg font-semibold text-fp-neutral-darkest mb-3">Daily Nutrient Targets</h2>

    <!-- Energy -->
    <div class="mb-4">
        <h3 class="text-sm font-medium text-fp-neutral-text-light mb-1">Energy</h3>
        <div class="flex justify-between items-center">
            <span class="text-2xl font-bold text-fp-primary-green"><%= nutrient_calculation&.dig(:energy, :eer_kcal_day) || '--' %> kcal</span>
            <span class="text-xs text-fp-neutral-text-light">Daily Target</span>
        </div>
    </div>

    <!-- Macronutrients -->
    <div class="grid grid-cols-3 gap-4 mb-4">
        <!-- Protein -->
        <div class="text-center">
            <h4 class="text-xs font-medium text-fp-neutral-text-light mb-1">Protein</h4>
            <div class="text-lg font-semibold text-fp-accent-blue">
                <%= nutrient_calculation&.dig(:macronutrients, :protein, :rda_g_total) || '--' %>g
            </div>
        </div>
        <!-- Carbs -->
        <div class="text-center">
            <h4 class="text-xs font-medium text-fp-neutral-text-light mb-1">Carbs</h4>
            <div class="text-lg font-semibold text-fp-accent-yellow">
                <%= nutrient_calculation&.dig(:macronutrients, :carbohydrates, :rda_g) || '--' %>g
            </div>
        </div>
        <!-- Fat -->
        <div class="text-center">
            <h4 class="text-xs font-medium text-fp-neutral-text-light mb-1">Fat</h4>
            <div class="text-lg font-semibold text-fp-primary-green">
                <%= nutrient_calculation&.dig(:macronutrients, :fat, :total_fat, :amdr, :grams, :min_grams) || '--' %>g
            </div>
        </div>
    </div>

    <!-- BMI -->
    <div class="border-t border-fp-neutral-medium pt-3">
        <div class="flex justify-between items-center">
            <div>
                <h3 class="text-sm font-medium text-fp-neutral-text-light">BMI</h3>
                <div class="text-lg font-semibold text-fp-neutral-darkest">
                    <%= nutrient_calculation&.dig(:bmi, :value) || '--' %>
                </div>
            </div>
            <div class="text-right">
                <span class="text-xs text-fp-neutral-text-light">Status</span>
                <div class="text-sm font-medium <%= bmi_status_color(nutrient_calculation&.dig(:bmi, :category)) %>">
                    <%= nutrient_calculation&.dig(:bmi, :category) || '--' %>
                </div>
            </div>
        </div>
    </div>

    <!-- Full DRI Report Button -->
    <div class="mt-4">
        <button id="fullDriReportBtn" class="w-full bg-fp-accent-blue text-white text-sm font-medium py-2 px-4 rounded-fp shadow-fp-cta hover:bg-fp-accent-blue-dark transition-colors">
            Full DRI Report
        </button>
    </div>
</div>
```

#### Step 4: Create Modal Partial
Create `app/views/shared/_modal.html.erb`:

```erb
<div id="<%= modal_id %>" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 hidden z-50">
    <div class="bg-white p-6 rounded-lg shadow-xl max-w-<%= max_width || 'sm' %> w-full max-h-[90vh] overflow-y-auto">
        <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-semibold"><%= title %></h2>
            <button id="<%= close_id %>" class="text-fp-neutral-text-light hover:text-fp-neutral-darkest">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </div>
        <%= content %>
    </div>
</div>
```

#### Step 5: Update Main View to Use Partials
Update `app/views/dashboard/show.html.erb`:

```erb
<!-- Header Area -->
<header class="p-5 bg-fp-neutral-lightest shadow-sm flex justify-between items-center">
    <div>
        <p class="text-xs text-fp-neutral-text-light">Tuesday, Oct 26</p>
        <h1 class="font-display-prototype text-2xl text-fp-neutral-darkest">Good Morning!</h1>
    </div>
    <button type="button" id="profileStatsBtn">
        <%= image_tag @current_user.avatar_url, alt: "User Avatar", class: "w-10 h-10 rounded-full border-2 border-fp-primary-green p-0.5 bg-white" %>
    </button>
</header>

<!-- Main Dashboard Area -->
<main class="main-dashboard-area">
    <!-- Eyebrow Quick Actions -->
    <div class="eyebrow-buttons-container">
        <button class="eyebrow-btn bg-fp-primary-green text-white text-xs font-medium py-2 px-3 sm:px-4 rounded-full shadow-fp-cta">Start Next Meal</button>
        <button class="eyebrow-btn bg-fp-accent-blue text-white text-xs font-medium py-2 px-3 sm:px-4 rounded-full shadow-fp-cta">Scan Barcode</button>
        <button class="eyebrow-btn bg-white text-fp-neutral-text text-xs font-medium py-2 px-3 sm:px-4 rounded-full border border-fp-neutral-medium shadow-sm">Quick Add Item</button>
        <button class="eyebrow-btn bg-white text-fp-neutral-text text-xs font-medium py-2 px-3 sm:px-4 rounded-full border border-fp-neutral-medium shadow-sm">Browse Recipes</button>
    </div>

    <!-- Timer and Nutrient Stats -->
    <div class="flex flex-col lg:flex-row gap-4 lg:gap-6">
        <%= render 'shared/timer' %>
        <%= render 'shared/nutrient_stats', nutrient_calculation: @nutrient_calculation %>
    </div>

    <!-- Upcoming Meals Section -->
    <section class="mt-8">
        <h2 class="text-lg font-semibold text-fp-neutral-darkest mb-3">Upcoming Meals</h2>
        
        <%= render 'shared/meal_item', meal: @current_meal, current: true %>
        <%= render 'shared/meal_item', meal: @next_meal %>
        <%= render 'shared/meal_item', meal: @future_meal %>
    </section>
</main>

<!-- Modals -->
<%= render 'shared/modal', 
    modal_id: 'personalStatsPopup',
    close_id: 'closeStatsPopupBtn',
    title: 'Your Activity',
    content: render('dashboard/personal_stats_content') %>

<%= render 'shared/modal', 
    modal_id: 'fullDriReportModal',
    close_id: 'closeDriReportBtn',
    max_width: '2xl',
    title: 'Complete Dietary Reference Intake Report',
    content: render('dashboard/dri_report_content', nutrient_calculation: @nutrient_calculation) %>
```

## 6. Remove Duplicate Tailwind Config

### Current Issue
Tailwind config is repeated in multiple views.

### Implementation Steps

#### Step 1: Create Tailwind Config File
Create `tailwind.config.js` in the root directory:

```javascript
module.exports = {
  content: [
    './app/views/**/*.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: { 
        sans: ['Poppins', 'sans-serif'], 
        display: ['Satisfy', 'cursive'] 
      },
      colors: {
        'fp-body-bg': '#E7F1D3',
        'fp-primary-green': '#5AD479',
        'fp-primary-green-dark': '#34C759',
        'fp-accent-blue': '#5A6AD4',
        'fp-accent-blue-dark': '#4755c4',
        'fp-neutral-text': '#111827',
        'fp-neutral-darkest': '#333333',
        'fp-neutral-lightest': '#FBFDF8',
        'fp-white': '#FFFFFF',
        'fp-neutral-medium': '#D1D5DB',
        'fp-error': '#DC3545',
        'fp-accent-yellow': '#F0AB1F',
        'fp-neutral-text-light': '#6B7280',
        'gray-100': '#f3f4f6',
      },
      boxShadow: { 
        'fp-cta': '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)', 
        'fp-card': '0 2px 8px rgba(0,0,0,0.07)' 
      },
      borderRadius: { 
        'fp': '0.5rem' 
      }
    }
  },
  plugins: []
}
```

#### Step 2: Remove Inline Config
Remove the Tailwind config from all views.

## 7. Improve Asset Organization

### Current Issues
- Font imports are in the view instead of CSS
- Some styles are duplicated across views

### Implementation Steps

#### Step 1: Move Font Imports to CSS
Add to `app/assets/stylesheets/application.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&family=Satisfy&display=swap');
```

#### Step 2: Remove Font Import from View
Remove the Google Fonts link from the view.

## 8. Fix Accessibility Issues

### Current Issues
- Missing ARIA labels on interactive elements
- Color contrast may not meet WCAG standards
- Keyboard navigation not properly implemented

### Implementation Steps

#### Step 1: Add ARIA Labels
Update interactive elements:

```erb
<!-- Add aria-label to buttons -->
<button type="button" id="profileStatsBtn" aria-label="View personal statistics">
    <%= image_tag @current_user.avatar_url, alt: "User Avatar", class: "w-10 h-10 rounded-full border-2 border-fp-primary-green p-0.5 bg-white" %>
</button>

<!-- Add role and aria-label to timer -->
<div class="circular-timer-demo" id="dashboardLiveTimer" role="timer" aria-label="Meal preparation timer">
    <!-- timer content -->
</div>

<!-- Add aria-expanded to modals -->
<button id="fullDriReportBtn" aria-expanded="false" aria-controls="fullDriReportModal">
    Full DRI Report
</button>
```

#### Step 2: Improve Color Contrast
Update color classes to ensure sufficient contrast:

```css
/* Ensure text colors meet WCAG AA standards */
.text-fp-neutral-text-light {
    color: #6B7280; /* Ensure this meets contrast requirements */
}

.text-fp-neutral-text {
    color: #111827; /* Ensure this meets contrast requirements */
}
```

#### Step 3: Add Keyboard Navigation
Update JavaScript to handle keyboard events:

```javascript
// Add to modal component
handleKeydown(event) {
    if (event.key === 'Escape') {
        this.close();
    }
}

init() {
    // ... existing code ...
    document.addEventListener('keydown', (event) => this.handleKeydown(event));
}
```

## 9. Optimize Performance

### Current Issues
- Large inline styles and scripts block rendering
- No lazy loading for images
- Timer runs continuously even when not visible

### Implementation Steps

#### Step 1: Add Lazy Loading to Images
Update image tags:

```erb
<%= image_tag @current_user.avatar_url, alt: "User Avatar", class: "w-10 h-10 rounded-full border-2 border-fp-primary-green p-0.5 bg-white", loading: "lazy" %>
```

#### Step 2: Optimize Timer Performance
Add visibility API to pause timer when not visible:

```javascript
// Add to Timer class
constructor(timerId) {
    // ... existing code ...
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
    document.addEventListener('visibilitychange', this.handleVisibilityChange);
}

handleVisibilityChange() {
    if (document.hidden) {
        if (this.intervalId) {
            clearInterval(this.intervalId);
            this.intervalId = null;
        }
    } else {
        if (!this.intervalId) {
            this.intervalId = setInterval(() => this.tick(), 1000);
        }
    }
}
```

#### Step 3: Use CSS Containment
Add CSS containment to improve rendering performance:

```css
.main-dashboard-area {
    contain: layout style paint;
    /* ... existing styles ... */
}
```

## 10. Use Rails Helpers and Partials

### Current Issues
- Hardcoded image URLs instead of asset helpers
- Repeated HTML structures
- No use of Rails form helpers for modals

### Implementation Steps

#### Step 1: Use Asset Helpers
Replace hardcoded image URLs:

```erb
<!-- Instead of hardcoded images -->
<img src="https://images.unsplash.com/photo-1546069901-ba9599a7e63c?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Spaghetti Carbonara" class="w-16 h-16 rounded-md object-cover">

<!-- Use asset helpers -->
<%= image_tag "meals/spaghetti-carbonara.jpg", alt: "Spaghetti Carbonara", class: "w-16 h-16 rounded-md object-cover", loading: "lazy" %>
```

#### Step 2: Use Rails Form Helpers for Modals
Create form helpers for modal content:

```erb
<!-- In modal partial -->
<%= form_with url: "#", local: true, class: "space-y-4" do |form| %>
    <%= form.label :search, "Search", class: "form-label-fp" %>
    <%= form.text_field :search, class: "form-input-fp" %>
<% end %>
```

#### Step 3: Use Rails Path Helpers
Replace hardcoded URLs with Rails path helpers:

```erb
<!-- Instead of hardcoded URLs -->
<a href="/recipes">Browse Recipes</a>

<!-- Use path helpers -->
<%= link_to "Browse Recipes", recipes_path, class: "eyebrow-btn bg-white text-fp-neutral-text text-xs font-medium py-2 px-3 sm:px-4 rounded-full border border-fp-neutral-medium shadow-sm" %>
```

## Implementation Priority

1. **High Priority**: Extract CSS and JavaScript (Steps 1-3)
2. **High Priority**: Use Rails layout system (Step 4)
3. **Medium Priority**: Extract reusable components (Step 5)
4. **Medium Priority**: Fix mobile responsiveness (Step 2)
5. **Low Priority**: Performance optimizations (Step 9)
6. **Low Priority**: Accessibility improvements (Step 8)

## Testing Checklist

After implementing these refactoring changes:

- [ ] Dashboard loads correctly on mobile devices
- [ ] Timer functionality works as expected
- [ ] Modals open and close properly
- [ ] All images load correctly
- [ ] CSS styles are applied correctly
- [ ] JavaScript functionality is preserved
- [ ] No console errors
- [ ] Performance is maintained or improved
- [ ] Accessibility features work correctly

## Conclusion

These refactoring opportunities will significantly improve the dashboard view's maintainability, performance, and adherence to Rails conventions. The changes should be implemented incrementally, starting with the highest priority items, and thoroughly tested at each step. 