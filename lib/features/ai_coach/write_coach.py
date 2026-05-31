code = open('lib/features/ai_coach/ai_coach_template.dart', 'r', encoding='utf-8').read()
with open('lib/features/ai_coach/ai_coach_screen.dart', 'w', encoding='utf-8') as f:
    f.write(code)
print('done')
