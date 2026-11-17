"""Prueba de integracion del cliente real. Requiere Python y playwright instalados."""
import json
import subprocess
from datetime import datetime
from pathlib import Path
from playwright.sync_api import sync_playwright, expect

ROOT = Path(__file__).resolve().parent.parent
REPORT = ROOT / 'evidencias'

def docker(*args):
    p = subprocess.run(['docker', 'compose', *args], cwd=ROOT, capture_output=True, text=True)
    if p.returncode:
        raise RuntimeError(p.stderr)
    return p.stdout + p.stderr

def main():
    records = []
    def record(text):
        records.append(text)
        print(text)
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={'width':1366, 'height':1000}, locale='es-EC')
        errors = []
        page.on('pageerror', lambda e: errors.append(str(e)))
        page.goto('http://localhost:8080/')
        expect(page.locator('#refresh')).to_be_enabled()
        titulo = 'Informe de Docker web ' + datetime.now().strftime('%H:%M:%S')
        page.locator('#title').fill(titulo)
        page.locator('#description').fill('Entrega creada desde el cliente web y guardada en PostgreSQL.')
        page.locator('#due').fill('2026-11-27')
        page.get_by_role('button', name='Crear tarea', exact=True).click()
        expect(page.locator('#form-message')).to_have_text('Tarea creada.')
        expect(page.get_by_role('heading', name=titulo, exact=True)).to_be_visible()
        tareas = page.request.get('http://localhost:8080/v1/tareas').json()
        assert any(t['titulo'] == titulo for t in tareas)
        record('OK: tarea creada por formulario y encontrada mediante GET /v1/tareas')
        page.locator('#search').fill(titulo)
        check = page.get_by_role('checkbox', name=f'Completar: {titulo}', exact=True)
        check.check()
        expect(page.get_by_role('heading', name=titulo, exact=True)).not_to_be_visible()
        page.get_by_role('button', name='Completadas', exact=True).click()
        expect(page.get_by_role('heading', name=titulo, exact=True)).to_be_visible()
        page.get_by_role('checkbox', name=f'Marcar pendiente: {titulo}', exact=True).uncheck()
        page.get_by_role('button', name='Pendientes', exact=True).click()
        expect(page.get_by_role('heading', name=titulo, exact=True)).to_be_visible()
        record('OK: completar y volver a pendiente mediante PATCH; filtros y busqueda')
        page.locator('#search').fill('')
        record(docker('stop','api1','api3'))
        try:
            page.get_by_role('button', name='Actualizar', exact=True).click()
            expect(page.get_by_role('heading', name=titulo, exact=True)).to_be_visible()
            page.locator('#title').fill('Entrega con una sola replica')
            page.get_by_role('button', name='Crear tarea', exact=True).click()
            expect(page.locator('#form-message')).to_have_text('Tarea creada.')
            expect(page.get_by_role('heading', name='Entrega con una sola replica', exact=True)).to_be_visible()
            response = page.request.get('http://localhost:8080/v1/tareas')
            assert response.ok
            record('OK: lectura y creacion web con api1 y api3 detenidas; X-Replica=' + response.headers.get('x-replica',''))
            (REPORT/'web-tareas.json').write_text(json.dumps(response.json(),ensure_ascii=False,indent=2),encoding='utf-8')
            page.screenshot(path=str(REPORT/'captura-web.png'), full_page=True)
            page.set_viewport_size({'width':390,'height':844})
            page.screenshot(path=str(REPORT/'captura-web-movil.png'), full_page=True)
            assert page.evaluate('document.documentElement.scrollWidth <= window.innerWidth')
            record('OK: capturas escritorio/movil; sin desbordamiento horizontal a 390 px')
        finally:
            record(docker('start','api1','api3'))
        assert not errors, errors
        record('OK: sin errores JavaScript en el navegador')
        browser.close()
    (REPORT/'08-web.log').write_text('\n'.join(records),encoding='utf-8')

if __name__ == '__main__':
    main()
