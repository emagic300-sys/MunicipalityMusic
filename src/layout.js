(()=>{
  function arrange(){
    const main=document.querySelector('main.shell');
    const hero=document.querySelector('.hero');
    const dash=document.querySelector('#dash');
    const search=document.querySelector('.hero .search');
    if(!main||!hero||!dash||!search||main.dataset.layoutReady)return;

    main.dataset.layoutReady='true';
    let zone=document.createElement('section');
    zone.className='search-zone';
    zone.id='search-events';
    zone.innerHTML='<h2>Find an event</h2><p>Search by performer, event, town, venue, category or genre.</p>';
    zone.append(search);
    dash.after(zone);

    const curated=document.querySelector('.features')?.parentElement;
    if(curated)main.append(curated);

    const jump=document.createElement('button');
    jump.type='button';
    jump.className='primary hero-search-button';
    jump.textContent='Search events';
    jump.onclick=()=>{
      zone.scrollIntoView({behavior:'smooth',block:'start'});
      window.setTimeout(()=>document.querySelector('#search')?.focus(),350);
    };
    hero.append(jump);
  }

  arrange();
  const app=document.querySelector('#app');
  if(app)new MutationObserver(()=>window.requestAnimationFrame(arrange)).observe(app,{childList:true,subtree:true});
})();
