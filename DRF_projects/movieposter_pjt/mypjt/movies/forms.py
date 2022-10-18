from xml.etree.ElementTree import Comment
from django import forms
from .models import Movie, Comment

class MovieForm(forms.ModelForm):
    GERNE_A = '코미디'
    GERNE_B = '공포'
    GERNE_C = '로맨스'
    GERNE_CHOICES = [
        (GERNE_A, '코미디'),
        (GERNE_B, '공포'),
        (GERNE_C, '로맨스'),
    ]
    title = forms.CharField(
        widget=forms.TextInput(
            attrs={
                'class':'my-title w-100',
                'maxlength':10,
                'placeholder':'title',
            }
        )
    )
    audience = forms.IntegerField(
                widget=forms.NumberInput(
            attrs={
                'class':'w-100',
                'type':'number',
                'placeholder':'audience',
            }
        )
    )
    release_date = forms.DateField(
        widget=forms.DateInput(
            attrs={
                'class':'w-100',
                'type':'date',
            }
        )
    )
    gerne = forms.ChoiceField(choices=GERNE_CHOICES, 
        widget=forms.Select(
            attrs={
                'class':'w-100',
                'maxlength':7,
            }
        )
    )
    score = forms.FloatField(
        widget=forms.NumberInput(
            attrs={
                'class':'w-100',
                'step':'0.5', 'min':0, 'max':5, 'type':'number',
                'placeholder':'score',

            }
        )
    )
    poster_url = forms.CharField(
        widget = forms.Textarea(
            attrs={
                'class':'my-content w-100',
                'placeholder':'Content',
            }
        )
    ) 
    description = forms.CharField(
        widget = forms.Textarea(
            attrs={
                'class':'my-content w-100',
                'placeholder':'Content',
            }
        )
    )
    
    class Meta:
        model = Movie
        fields = '__all__'

class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ('content',)
        
