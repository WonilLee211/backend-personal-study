from telnetlib import STATUS
from django.shortcuts import get_list_or_404, get_object_or_404, render
from .models import Music, Artist
from .serializers import (
    MusicSerializer, MusicListSerializer, ArtistListSerializer, ArtistSerializer
    )
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view

from music import serializers
# Create your views here.



@api_view(["GET", "POST"])
def artists_cr(request):
    if request.method == "GET":
        artists = get_list_or_404(Artist)
        serializer = ArtistListSerializer(artists, many=True)
        return Response(serializer.data, status = status.HTTP_200_OK)
    
    elif request.method == "POST":
        serializer = ArtistListSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(["GET"])
def artist_r(request, artist_pk):
    artist = get_object_or_404(Artist, pk=artist_pk)
    serializer = ArtistSerializer(artist)
    return Response(data=serializer.data, status = status.HTTP_200_OK)



    
@api_view(["POST"])
def music_c(request, artist_pk):
    serializer = MusicSerializer(data=request.data)
    artist = get_object_or_404(Artist, pk=artist_pk)

    if serializer.is_valid(raise_exception=True):
        serializer.save(artist=artist)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
    
@api_view(["GET"])
def music_r(request):
    music_list = get_list_or_404(Music)
    serializer = MusicListSerializer(music_list, many=True)
    return Response(serializer.data, status = status.HTTP_200_OK)   

@api_view(["GET", "PUT", "DELETE"])    
def music_rud(request, music_pk):
    music = get_object_or_404(Music, pk=music_pk)
    
    if request.method == "GET":
        serializer = MusicSerializer(music)
        return Response(serializer.data, status=status.HTTP_200_OK)
    elif request.method == "PUT":
        serializer = MusicSerializer(music, data=request.data)
        if serializer.is_valid(raise_exception=True):
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)
    elif request.method == "DELETE":
        music.delete()
        return Response({'id':music_pk}, status=status.HTTP_204_NO_CONTENT)
        
