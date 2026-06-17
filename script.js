document.addEventListener('DOMContentLoaded', () => {
    
    // --- HLD Interactive Info Panel ---
    const hldInfoPanel = document.getElementById('hld-info');
    const hldTitle = document.getElementById('hld-title');
    const hldDesc = document.getElementById('hld-desc');
    
    const blockDescriptions = {
        'bus-if': {
            title: 'Bus Interface',
            desc: 'Connects Verichip to the 7-bit address bus and 16-bit data bus. Decodes chip_select, rw_, and byte_en[1:0] for memory-mapped I/O.'
        },
        'reg-file': {
            title: 'Register File',
            desc: 'Contains 7 memory-mapped registers: Version (RO), Status, Command, Config, Left ALU Input, Right ALU Input, and ALU Output (RO).'
        },
        'alu': {
            title: 'Arithmetic Logic Unit',
            desc: 'Executes 16-bit operations: ADD, SUB, MVL (Move Left), MVR (Move Right), SWA (Swap), SHL (Shift Left), SHR (Shift Right). Calculates Overflow.'
        },
        'int-ctrl': {
            title: 'Interrupt Controller',
            desc: 'Generates interrupt_1 (bad command or overflow) and interrupt_2 (export violation). Configured via Config Register and cleared via Status Register.'
        },
        'fsm': {
            title: 'State Machine',
            desc: 'Tracks operational status (RESET, NORMAL, ERROR, EXP_VIO, LOST). Transitions governed by external pins (maroon, gold) and internal exceptions.'
        }
    };

    document.querySelectorAll('.block.module').forEach(block => {
        block.addEventListener('mouseenter', (e) => {
            const id = e.currentTarget.id;
            if (blockDescriptions[id]) {
                hldTitle.textContent = blockDescriptions[id].title;
                hldDesc.textContent = blockDescriptions[id].desc;
                hldInfoPanel.classList.add('active');
            }
        });
        
        block.addEventListener('mouseleave', () => {
            hldInfoPanel.classList.remove('active');
            hldTitle.textContent = 'System Architecture';
            hldDesc.textContent = 'Hover over a component to see its details. Verichip features a 16-bit architecture with a robust State Machine.';
        });
    });

    // --- Circular Progress Animation ---
    // Trigger animations when scrolled into view
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if(entry.isIntersecting) {
                const circle = entry.target.querySelector('.meter');
                const val = entry.target.style.getPropertyValue('--val');
                // The CSS transition handles the animation when we reset the offset
                circle.style.strokeDashoffset = `calc(251.2 - (251.2 * ${val}) / 100)`;
            }
        });
    }, { threshold: 0.5 });

    document.querySelectorAll('.circular-progress').forEach(progress => {
        // Reset initially so it can animate in
        progress.querySelector('.meter').style.strokeDashoffset = '251.2';
        observer.observe(progress);
    });

    // --- FSM Animation ---
    const states = [
        { id: 'state-reset', pos: { top: '20%', left: '50%' } },
        { id: 'state-norm', pos: { top: '50%', left: '50%' } },
        { id: 'state-err', pos: { top: '80%', left: '30%' } },
        { id: 'state-norm', pos: { top: '50%', left: '50%' } },
        { id: 'state-exp', pos: { top: '80%', left: '70%' } },
        { id: 'state-reset', pos: { top: '20%', left: '50%' } }
    ];
    
    let currentStateIdx = 0;
    const token = document.getElementById('fsm-token');
    
    function animateFSM() {
        // Remove active class from all
        document.querySelectorAll('.fsm-node').forEach(node => node.classList.remove('active'));
        
        const stateInfo = states[currentStateIdx];
        const stateEl = document.getElementById(stateInfo.id);
        
        if (stateEl) {
            stateEl.classList.add('active');
            token.style.top = stateInfo.pos.top;
            token.style.left = stateInfo.pos.left;
        }

        currentStateIdx = (currentStateIdx + 1) % states.length;
        setTimeout(animateFSM, 2000); // 2 second per transition
    }

    // Start FSM animation
    animateFSM();
});
